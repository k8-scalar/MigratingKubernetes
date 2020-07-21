#!/bin/bash
mkdir $1-junit
mkdir $1-e2e-log
for i in `ls $1`
do
  echo $i
  #cp $1/$i/plugins/e2e/results/e2e.log  $1-e2e-log/$i.log
   cp `find $1/$i/ | grep e2e.log` $1-e2e-log/$i.log
  #cp $1/$i/plugins/e2e/results/junit_01.xml $1-junit/$i.xml
   cp `find $1/$i/ | grep junit_01.xml` $1-junit/$i.xml
done


