#!/bin/bash
mkdir $1
cd results
for i in `ls $1_*`
do
  v=${i::-7}
  echo $v
  mkdir ../$1/$v
  cd ../$1/$v
  tar xvzf  ../../results/$i
  cd ../../results
done
cd ..
#  tar xvzf $i
