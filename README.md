# Zero-Shot Transfer Learning with Synthesized Data for Multi-Domain Dialogue State Tracking

This repository is the artifact associated with our paper, which was published in ACL 2020.

You can use this repository to reproduce our experiments exactly.
If you use any of the software in this repository, please cite:

```bibtex
@inproceedings{
...
}
```

## Setup

To reproduce our papers, you need the following repositories, and their exact version:

- <https://github.com/stanford-oval/trade-dst> tag acl2020-submission (d2326a446f07124d2d5babe676fef54dd1b04491)
- <https://github.com/stanford-oval/genie-toolkit> tag acl2020-submission (d37d0c01735d14c32fd699e358405e22b9cf51be)

Edit the first two lines of the `Makefile` to point to the directories where you cloned those repositories.

You will also need the following packages:
- nodejs (version 10.*)
- yarn
- python3 (>=3.6)
- git
- a working c++ compiler
- make
- gettext
- unzip

To install the dependencies for genie-toolkit, run the following inside the genie-toolkit clone:
```
yarn install
```

To install the dependencies for trade-dst, run the following inside the trade-dst clone:
```
pip3 install -r requirements.txt
```

NOTE: the trade-dst repository includes the scripts and Dockerfiles that we used to run on Kubernetes. These scripts might be useful, if you have a Kubernetes cluster on AWS. The documentation for these scripts is provided at <https://github.com/stanford-oval/genie-k8s>.

## Pretrained Models

The following pretrained models are availabe:

- {trade-dst,sumbt}/baseline: trained with full dataset
- {trade-dst,sumbt}/augmented: trained with full dataset and synthesized data
- trade-dst/except-{attraction,hotel,restaurant,taxi,train}-original: trained in zero-shot fashion, with the original zero-shot strategy
- {trade-dst,sumbt}/except-{attraction,hotel,restaurant,taxi,train}-pct0: new zero-shot baseline
- {trade-dst,sumbt}/except-{attraction,hotel,restaurant,taxi,train}-pct0-augmented: our approach: zero-shot with synthesized data and domain adaptation
- {trade-dst,sumbt}/except-{attraction,hotel,restaurant,taxi,train}-pct{1,5,10}: few-shot baseline
- {trade-dst,sumbt}/except-{attraction,hotel,restaurant,taxi,train}-pct{1,5,10}-augmented: few-shot training with synthesized data and domain adaptation 

Pretrained models can be downloaded from <https://oval.cs.stanford.edu/releases/acl2020/> by appending the model name and `.tar.xz`. For example, the `trade-dst/baseline` model can be downloaded from <https://oval.cs.stanford.edu/releases/acl2020/trade-dst/baseline.tar.xz>.

For convenience, all pretrained models can be downloaded at once with the command:
```bash
make download-pretrained
```

## Evaluating The Trained Models

To evaluate a model, first download the original MultiWOZ 2.1 dataset (containing the dev and test sets) in the `data` directory, using:
```bash
make data
```

Place the models you wish to evaluate in `models/`, unpacked, one model per directory (e.g. the `trade-dst/baseline` model should have a `models/trade-dst/baseline` directory). Add them in the `eval_models` variable in the Makefile.
Then execute:
```bash
make evaluate
```

This command will place a `results` file in each model directory.
For a TRADE model, the file will contain the evaluation on the full test set (line "Everything"), and on each domain individually (all dialogues that include that domain, for the subset of slots in that domain, lines "Only X"). The results file contains three columns for each evaluation: joint accuracy, slot accuracy, and slot F1 (not reported in the paper).
For a SUMBT model, the file will contain the evaluation on the full test set (line "joint acc : slot acc"), and on each domain individually (all dialogues that include that domain, for the subset of slots in that domain, lines "joint X: slot acc X"). The results file contains two columns for each evaluation: joint accuracy and slot accuracy.

### Table 3: Accuracy on the full MultiWOZ dataset

To reproduce this table, evaluate these models:
- row "TRADE no": trade-dst/baseline
- row "TRADE yes": trade-dst/augmented
- row "SUMBT no": sumbt/baseline
- row "SUMBT yes": sumbt/augmented

After evaluation, look for the `results` file. The table numbers will match the line prefixed with "Everything".

### Table 4: Accuracy on the zero-shot MultiWOZ experiment

To reproduce this table, evaluate these models:
- row "TRADE full dataset" and "SUMBT full dataset": evaluate as in the previous section, then look for result lines prefixed with "Only X"
- row "TRADE original zero shot": evaluate the models "trade-dst/except-*-original"; in each model, look for the result lines prefixed with "Only X" for the corresponding "X" (e.g. for the column "Restaurant", evaluate the model "trade-dst/except-restaurant-original" and look for the lines "Only restaurant")
- row "TRADE zero-shot baseline": evaluate the models "trade-dst/except-*-pct0"; in each model, look for the result lines prefixed with "Only X" for the corresponding "X" (e.g. for the column "Restaurant", evaluate the model "trade-dst/except-restaurant-pct0" and look for the lines "Only restaurant")
- row "TRADE out zero-shot": evaluate the models "trade-dst/except-*-pct0-augmented" 
- row "SUMBT zero-shot baseline": evaluate the models "sumbt/except-*-pct0"; in each model, look for the result lines prefixed with "Only X" for the corresponding "X" (e.g. for the column "Restaurant", evaluate the model "trade-dst/except-restaurant-pct0" and look for the lines "Only restaurant")
- row "SUMBT out zero-shot": evaluate the models "sumbt/except-*-pct0-augmented" 

### Figure 4: Few-shot MultiWOZ experiment

To draw each plot, use the joint accuracy computed from the models "trade-dst/except-*-pct{0,1,5,10}" and "sumbt/except-*-pct{0,1,5,10}", e.g. for the "Restaurant" plot consider the models "trade-dst/except-restaurant-pct{0,1,5,10}" and "submt/except-restaurant-pct{0,1,5,10}". The models suffixed with "-augmented" include synthesis, and the models without suffix are baselines.

## Generating New Fresh Datasets

To generate a new dataset, use the command:

```bash
make data-generated transfer_from_domain=... transfer_to_domain=... synthetic_gen_domains=... fewshot_pct=... synthetic_sample_prob=...
```

The dataset is generated in the "data-generated" directory. You must copy/move that directory elsewhere to avoid clobbering it with multiple invocations of the generation command.

The data is generated in TRADE format. To convert to SUMBT format, use `make data-sumbt` for the regular dataset, and `make data-generated-sumbt` for a generated dataset.

To generate the full dataset (all domains, with augmentation), use:
```bash
make data-generated transfer_from_domain= transfer_to_domain= synthetic_gen_domains="attraction hotel restaurant taxi train" synthetic_sample_prob=0.03
```

To generate the zero-shot datasets with synthesis and domain transfer, use:
```bash
make data-generated transfer_from_domain=restaurant transfer_to_domain=attraction synthetic_gen_domains=attraction fewshot_pct=0 synthetic_sample_prob=0.06
make data-generated transfer_from_domain=restaurant transfer_to_domain=hotel synthetic_gen_domains=hotel fewshot_pct=0 synthetic_sample_prob=0.06
make data-generated transfer_from_domain=hotel transfer_to_domain=restaurant synthetic_gen_domains=restaurant fewshot_pct=0 synthetic_sample_prob=0.06
make data-generated transfer_from_domain=train transfer_to_domain=taxi synthetic_gen_domains=taxi fewshot_pct=0 synthetic_sample_prob=0.06
make data-generated transfer_from_domain=taxi transfer_to_domain=train synthetic_gen_domains=train fewshot_pct=0 synthetic_sample_prob=0.06
```

Change `fewshot_pct` to generate a few-shot dataset.

To generate the zero-shot datasets for the baseline, use:

```bash
make data-generated transfer_from_domain= transfer_to_domain=attraction synthetic_gen_domains= fewshot_pct=0 synthetic_sample_prob=0
make data-generated transfer_from_domain= transfer_to_domain=hotel synthetic_gen_domains= fewshot_pct=0 synthetic_sample_prob=0
make data-generated transfer_from_domain= transfer_to_domain=restaurant synthetic_gen_domains= fewshot_pct=0 synthetic_sample_prob=0
make data-generated transfer_from_domain= transfer_to_domain=taxi synthetic_gen_domains= fewshot_pct=0 synthetic_sample_prob=0
make data-generated transfer_from_domain= transfer_to_domain=train synthetic_gen_domains= fewshot_pct=0 synthetic_sample_prob=0
```

**NOTE**: dataset generation is not perfectly deterministic, due to parallelism. The datasets that were used to train the pretrained models are available for download from <https://oval.cs.stanford.edu/releases/acl2020/dataset/> by appending the model suffix and `.tar.xz`. For example, the `augmented` dataset can be downloaded from <https://oval.cs.stanford.edu/releases/acl2020/dataset/augmented.tar.xz>, and the `except-restaurant-pct0-augmented` dataset can be downloaded from <https://oval.cs.stanford.edu/releases/acl2020/dataset/except-restaurant-pct0-augmented.tar.xz>.

## Training

### TRADE-DST

To train TRADE-DST, use the script:

```bash
./train-trade-dst.sh $tradedir $modeldir $datadir <hparams>
```

(`$tradedir` should be set to the full path to the trade-dst checkout directory)

The model will be trained on data contained in `$datadir` (which must be in the TRADE format), and will be saved to `$modeldir`. Later, it can be evaluated with:
```bash
./evaluate-trade-dst.sh $tradedir $modeldir
```

The models are trained with the recommended hyperparameters, except for a smaller batch size (that fits on a V100 GPU with 16GB of VRAM, available on AWS). You can change the hyperparameters from inside the train-trade-dst.sh script.

### SUMBT

To train SUBMT, use the script:

```bash
./train-sumbt.sh $sumbtdir $modeldir $datadir <hparams>
```

(`$sumbtdir` should be set to the full path to the trade-dst checkout directory)

The model will be trained on data contained in `$datadir` (which must be in the SUMBT format), and will be saved to `$modeldir`. Later, it can be evaluated with:
```bash
./evaluate-sumbt.sh $sumbtdir $modeldir
```

The models are trained with the recommended hyperparameters. You can change the hyperparameters from inside the train-sumbt.sh script.

## License

This repository (containing the evaluation scripts) is licensed under the MIT license. See the [LICENSE](LICENSE) for details.

Other repositories referred to but this one (including genie-toolkit, trade-dst, sumbt) are copyright of their respective authors, and are available under different licenses. You are responsible for complying with the copyright license in all the software you download and use.

Synthesized data includes data derived from domain-independent and domain-dependent templates, which are covered by the genie-toolkit license. If you use or distribute the synthesized data, you must comply with the genie-toolkit license.
