#!/bin/bash

set -e
set -x

tradedir="$1"
modeldir="$2"
datadir="$3"
modeldir=`realpath $modeldir`
datadir=`realpath $datadir`
shift
shift
shift

cd $tradedir
ln -sf "$modeldir" save
ln -sf "$srcdir/data" data

python3 myTrain.py "$@"
