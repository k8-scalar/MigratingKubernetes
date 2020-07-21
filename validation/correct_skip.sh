(cut -d, -f7 < $1_skip.csv) > tmp_skip.csv
(cut -d, -f7 < $1_fail.csv) > tmp_fail.csv
(cut -d, -f6,7 < $1_success.csv) > tmp_success.csv

(paste -d, tmp_success.csv tmp_fail.csv tmp_skip.csv) | tail -n+2 > $1_summary.csv
cat $1_skip.csv | tail -n+2 > skip2.csv 
#rm tmp_*.csv

echo 
while IFS=, read -r sig success fail skip && IFS=, read -r col1 col2 col3 col4 col5 col6 col7<&3 
do
  primer=$col1,$col2,$col3,$col4,$col5,$col6
  echo 'COl6: ' $col6
  echo 'sig: ' $sig
  echo 'Success log: ' $success
  echo 'Grepping:'
  echo '========'
  echo $success 
#| grep -o '$col6' 
#> success_hits
  echo $fail
#| grep  -o '$col6'
# > fail_hits
  echo $skip 
#| grep  -o '$col6'
# > skip_hits
done < $1_summary.csv 3<skip2.csv 
rm $1_summary.csv
rm skip2.csv

#while IFS= read -r lineA && IFS= read -r lineB <&3; do
#  echo "$lineA"; echo "$lineB"
#done <fileA 3<fileB

