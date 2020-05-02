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
python3 code/main-multislot.py --data_dir "$srcdir/data-sumbt" --output_dir "$modeldir" \
 --target_slot all --experiment multiwoz2.1 --bert_model bert-base-uncased --task_name bert-gru-sumbt --nbt rnn \
 --num_train_epochs 300 --do_lower_case --task_name bert-gru-sumbt --warmup_proportion 0.1 --learning_rate 1e-4 \
 --train_batch_size 3 --distance_metric euclidean --patience 15 --tf_dir tensorboard --hidden_dim 300 \
 --max_label_length 32 --max_seq_length 64 --do_eval "$@"
cp "$modeldir/eval_all_accuracies.txt" "$modeldir/results"
