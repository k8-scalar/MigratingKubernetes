for i in $PROVIDERS
do
  ./count.sh $i > ${i}_counts.csv 2>> ${i}_error.log
done
