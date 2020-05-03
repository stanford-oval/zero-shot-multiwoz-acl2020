#!/bin/bash

set -e
set -x

sumbtdir="$1"
modeldir="$2"
datadir="$3"
modeldir=`realpath $modeldir`
datadir=`realpath $datadir`
shift
shift
shift

cd $sumbtdir
python3 code/main-multislot.py --do_train --do_eval --data_dir "${datadir}" --output_dir "${modeldir}" \
  --experiment multiwoz --dataset "$dataset" --model "$model" -- \
  --target_slot all --experiment multiwoz2.1 \
  --bert_model bert-base-uncased --task_name bert-gru-sumbt --nbt rnn \
  --num_train_epochs 300 --do_lower_case --task_name bert-gru-sumbt \
  --warmup_proportion 0.1 --learning_rate 1e-4 --train_batch_size 3 --distance_metric euclidean \
  --patience 15 --tf_dir tensorboard --hidden_dim 300 --max_label_length 32 --max_seq_length 64 \
  --max_turn_length 22 "$@"
