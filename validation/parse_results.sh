./parse_csv.sh aks all > all.csv 2> all_error.log
for i in $PROVIDERS
do 
  ./parse_csv.sh $i success > ${i}_success.csv 2> ${i}_error.log
  ./parse_csv.sh $i fail > ${i}_fail.csv 2>> ${i}_error.log
  #./parse_csv.sh Si skip > ${i}_skip.csv 2>> ${i}_error.log
done

