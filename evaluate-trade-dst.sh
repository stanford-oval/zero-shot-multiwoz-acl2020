#!/bin/bash

set -e
set -x

tradedir="$1"
modeldir="$2"
modeldir=`realpath $modeldir`
srcdir=`realpath $PWD`
shift
shift

(cd "${modeldir}" ; test -a lang-all.pkl || ln -s TRADE*/lang-all.pkl lang-all.pkl )
(cd "${modeldir}" ; test -a mem-lang-all.pkl || ln -s TRADE*/mem-lang-all.pkl mem-lang-all.pkl )

# note: myTest is very, very broken, and assumes a very specific directory layout inside save/
cd $tradedir
ln -sfT "$modeldir" save
ln -sfT "$srcdir/data" data

best_model=$(ls -d save/TRADE*/HDD*BSZ* | sort -r | head -n1)

echo "Everything" > "$modeldir/eval.log"
python3 myTest.py -gs=1 -path "$best_model" "-bsz=32" "$@" | tee -a "$modeldir/eval.log"

for d in hotel train restaurant attraction taxi ; do
  echo "Only" $d >> "$modeldir/eval.log"
  python3 myTest.py -gs=1 -path "$best_model" -onlyd "$d" "-bsz=32" "$@" | tee -a "$modeldir/eval.log"
done

grep -E 'Joint Acc|Everything|Only ' "$modeldir/eval.log" | sed -E -e 's/F1/Fone/g' -e '/^(Only |Everything)/!s/[^0-9 .]/ /g' -e '/^(Only |Everything)/!s/ +/\t/g' > "${modeldir}/results"
