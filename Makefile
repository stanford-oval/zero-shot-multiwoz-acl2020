geniedir ?= $(HOME)/Projects/genie-toolkit
tradedir ?= $(HOME)/Projects/trade-dst
sumbtdir ?= $(HOME)/Projects/SUMBT

memsize := $(shell echo $$(($$(grep MemTotal /proc/meminfo | sed 's/[^0-9]//g')/1000-2500)))
parallel := $(shell echo $$(($$(grep processor /proc/cpuinfo | wc -l)-1)))
genie = node --experimental_worker --max_old_space_size=$(memsize) $(geniedir)/tool/genie.js

owner ?= gcampax

domains = attraction hotel restaurant taxi train
fewshot_experiments = 0 1 5 10

eval_models = \
	trade-dst/baseline \
	trade-dst/augmented \
	$(foreach d,$(domains),trade-dst/except-$(d)-original $(foreach fw,$(fewshot_experiments),trade-dst/except-$(d)-pct$(fw) trade-dst/except-$(d)-pct$(fw)-augmented))

first_turn_gen_flags = --target-pruning-size 50000 --maxdepth 9
dialog_gen_flags = --target-pruning-size 1000 --minibatch-size 10000 --max-turns 6 --maxdepth 6
#first_turn_gen_flags = --target-pruning-size 1000 --maxdepth 0
#dialog_gen_flags = --target-pruning-size 1000 --minibatch-size 15000 --debug --max-turns 3 --maxdepth 0

transfer_from_domain ?=
transfer_to_domain ?=
synthetic_gen_domains ?= attraction hotel restaurant taxi train
fewshot_pct ?= 0
synthetic_sample_prob ?= 0.3

all: data-generated

multiwoz-%.tsv: $(geniedir)/languages/multiwoz/domain-%.genie $(geniedir)/languages/multiwoz/first-turn.genie $(geniedir)/languages/multiwoz/shared.genie $(geniedir)/languages/multiwoz/*.js $(geniedir)/languages/multiwoz/*.json
	$(genie) generate  -o $@.tmp -t multidst -l en-US --template $< $(geniedir)/languages/multiwoz/first-turn.genie --no-debug $(first_turn_gen_flags)
	mv $@.tmp $@

synthetic-%.txt: multiwoz-%.tsv $(geniedir)/languages/multiwoz/domain-%.genie $(geniedir)/languages/multiwoz/contextual.genie $(geniedir)/languages/multiwoz/shared.genie $(geniedir)/languages/multiwoz/*.js $(geniedir)/languages/multiwoz/*.json
	$(genie) generate-dialogs -o $@.tmp -f txt-only -t multidst -l en-US --template $(geniedir)/languages/multiwoz/domain-$*.genie $(geniedir)/languages/multiwoz/contextual.genie --no-debug $(dialog_gen_flags) --parallelize $(parallel) -n `wc -l $<` $<
	mv $@.tmp $@

synthetic-%.json: multiwoz-%.tsv $(geniedir)/languages/multiwoz/domain-%.genie $(geniedir)/languages/multiwoz/contextual.genie $(geniedir)/languages/multiwoz/shared.genie $(geniedir)/languages/multiwoz/*.js $(geniedir)/languages/multiwoz/*.json
	$(genie) generate-dialogs -o $@.tmp -f json -t multidst -l en-US --template $(geniedir)/languages/multiwoz/domain-$*.genie $(geniedir)/languages/multiwoz/contextual.genie --no-debug $(dialog_gen_flags) --parallelize $(parallel) -n `wc -l $<` $<
	mv $@.tmp $@

synthetic-%.annotated.txt: multiwoz-%.tsv $(geniedir)/languages/multiwoz/domain-%.genie $(geniedir)/languages/multiwoz/contextual.genie $(geniedir)/languages/multiwoz/shared.genie $(geniedir)/languages/multiwoz/*.js $(geniedir)/languages/multiwoz/*.json
	$(genie) generate-dialogs -o $@.tmp -f txt -t multidst -l en-US --template $(geniedir)/languages/multiwoz/domain-$*.genie $(geniedir)/languages/multiwoz/contextual.genie --no-debug $(dialog_gen_flags) --parallelize $(parallel) -n `wc -l $<` $<
	mv $@.tmp $@

synthetic.json: $(foreach v,$(synthetic_gen_domains),synthetic-$(v).json)
	python3 ./concat-json.py $^ > $@

synthetic-trade.json: synthetic.json data
	python3 $(tradedir)/genie-to-trade.py synthetic.json > $@

train_dials.json: synthetic-trade.json data
	if test "x$(transfer_to_domain)" = "x" ; then \
	  python3 $(tradedir)/augment.py synthetic-trade.json $(synthetic_sample_prob) > $@ ; \
	else \
	  python3 $(tradedir)/transfer-dataset.py synthetic-trade.json "$(transfer_from_domain)" "$(transfer_to_domain)" "$(fewshot_pct)" "$(if $(transfer_from_domain),yes,no)" "$(synthetic_sample_prob)" > $@ ; \
	fi

clean:
	rm -fr synthetic* train_dials.json data-generated

data:
	mkdir -p $@
	python3 $(tradedir)/create_data.py
	cp $(geniedir)/languages/multiwoz/ontology.json $@/clean-ontology.json
	touch $@

data-generated: train_dials.json data/dev_dials.json data/test_dials.json original-ontology.json
	mkdir -p $@
	cp train_dials.json data/dev_dials.json data/test_dials.json $@
	mkdir -p $@/multi-woz/MULTIWOZ2.1
	cp original-ontology.json $@/multi-woz/MULTIWOZ2.1/ontology.json
	touch $@

data%-sumbt: data%
	mkdir -p $@
	python3 $(sumbtdir)/code_base/transform_augmented_data.py --input_dir $< --output_dir $@

models/trade-dst/%/results:
	./evaluate-trade-dst.sh "$(tradedir)" "models/trade-dst/$*"

models/sumbt/%/results:
	python3 $(sumbtdir)/code_base/

evaluate: $(foreach v,$(eval_models),models/$(v)/results)
	for f in $^ ; do echo $$f ; cat $$f ; done
