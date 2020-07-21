#!/bin/bash
rm all*
for i in $PROVIDERS 
do
  rm -r $i
  rm ${i}_counts.csv
done
