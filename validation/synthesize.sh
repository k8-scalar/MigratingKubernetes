(cut -d, -f1,2,3,4,5,6,7 < all.csv) > tmp_start.csv
for i in $PROVIDERS 
do 
  (paste -d, tmp_start.csv ${i}_counts.csv) > Summary.csv
   cat Summary.csv > tmp_start.csv
done
rm tmp_*.csv
:
