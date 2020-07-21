#export PROVIDERS="aks-1.13-np eks-1.13-np gke-1.13-np"
export PROVIDERS="aks eks gke aks-1.13 eks-1.13 gke-1.13"
export XML_TEMPLATE="aks-1.13_junit.xml"
if [ ! -d "run-results" ]
then
  mkdir run-results
else
  rm -r run-results/*
fi
echo "1. Extracting and classifying sonobuoy's e2e-tests => junit.xml files and e2e-test logs per K8S vendor aggregated in directory run-results..." 
./aggregate.sh > aggregate.log 2> aggregate_error.log
echo "2a. Processing all tests: classifying succeeded and failed tests => For each K8s vendor, 2 csv files are generated in directory run-results: one with succeeded tests and one with failed tests. This processing may take several minutes..."
./parse_results.sh
echo "2b. Processing all tests: counting number of succceeded and failed tests and generating summary => run-results/Summary.csv...."
./counts.sh
./synthesize.sh
./clean-up-intermediate.sh
for i in $PROVIDERS 
do
 mv ${i}* run-results
done
mv Summary.csv run-results
mv *.log run-results
echo "Run completed successfully!"
echo "To delete all results of this run, execute './cleanup.sh'"
