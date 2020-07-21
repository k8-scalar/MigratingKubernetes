#(cut -d, -f7 < $1_skip.csv) > tmp_skip.csv
(cut -d, -f7 < $1_fail.csv) > tmp_fail.csv
(cut -d, -f7 < $1_success.csv) > tmp_success.csv

(paste -d, tmp_success.csv tmp_fail.csv) | tail -n+2 > $1_summary.csv
#(paste -d, tmp_success.csv tmp_fail.csv tmp_skip.csv) | tail -n+2 > $1_summary.csv
rm tmp_*.csv

echo $1_success,$1_fail
#echo $1_success,$1_fail,$1_skip
while IFS=, read -r success fail
#while IFS=, read -r success fail skip 
do
  success_count=$(echo $success | grep -o '<testcase' | wc -l )
  fail_count=$(echo $fail | grep  -o '<fail' | wc -l)
  echo $success_count,$fail_count
#  skip_count=$(echo $skip | grep  -o  '<testcase' | wc -l)
#  echo $success_count,$fail_count,$skip_count
done < $1_summary.csv
rm $1_summary.csv
