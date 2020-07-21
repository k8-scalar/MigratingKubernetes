#!/bin/bash
for i in $PROVIDERS
do
rm -r $i*
./extract.sh $i
./classify.sh $i
done
