#!/bin/bash

set -e
set -x

sumbtdir="$1"
modeldir="$2"
modeldir=`realpath $modeldir`
srcdir=`realpath $PWD`
shift
shift

cd $sumbtdir
python3 code_base/main-multislot.py --data_dir "$srcdir/data-sumbt" --output_dir "$modeldir" \
 --target_slot all --experiment multiwoz2.1 --bert_model bert-base-uncased --task_name bert-gru-sumbt --nbt rnn \
 --num_train_epochs 300 --do_lower_case --task_name bert-gru-sumbt --warmup_proportion 0.1 --learning_rate 1e-4 \
 --train_batch_size 3 --distance_metric euclidean --patience 15 --tf_dir tensorboard --hidden_dim 300 \
 --max_label_length 32 --max_seq_length 64 --do_eval "$@"

#grep -E 'Joint Acc|Everything|Only ' "$modeldir/eval.log" | sed -E -e 's/F1/Fone/g' -e '/^(Only |Everything)/!s/[^0-9 .]/ /g' -e '/^(Only |Everything)/!s/ +/\t/g' > "${modeldir}/results"
