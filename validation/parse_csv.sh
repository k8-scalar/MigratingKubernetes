csvFile="./mapping_of_e2e_tests_to_features.csv"
if [ "$2" == "all" ]
then
  echo Feature type,Feature description,K8s provider,Feature config,Configuration proof,Relevant SIG test description,Nr of relevant tests
fi 
if [ "$2" != "all" ]
then
  echo Feature type,Feature description,K8s provider,Feature config,Configuration proof,Relevant SIG test description,Result
fi
while IFS=, read -r col1 col2 col3 col4 col5 col6
do
    primer=$col1,$col2,$col3,$col4,$col5
    i=1 
    x=`echo $col6 | cut -d ',' -f $i`
    while [ "$x" != "n/a" ]
    do
      y=""
      if [ "$2" == "all" ] 
      then
        y=$(grep -c "<test.*$x" xml-templates/${XML_TEMPLATE})
      fi
      if [ "$2" == "fail" ]
      then
        y=$(grep -ozP "<test.*$x.*\n.*<$2" `find $1-junit/`)
      fi
      if [ "$2" == "skip" ]
      then
#        success=""
#        success=$(grep "<test.*$x.*case>" `find $1-junit/`)
#        fail=""
#        fail=$(grep -ozP "<test.*$x.*\n.*<fail.*" `find $1-junit/`)
#        if [ "$success" == "" ] && [ "$fail" == "" ]
#        then  
        y=$(for f in `ls $1-junit/`; do grep 'classname=\"Kubernetes e2e suite\" time=\"0\">' $1-junit/$f | grep "$x"; done | sort -u)
#        fi 
      fi
      if [ "$2" == "success" ]
      then
	  y=$(grep "<test.*$x.*case>" `find $1-junit/`)
      fi
      y=${y//$'\n'/'.'} 
      y=${y//','/';'} 
      echo $primer,$x,$y 
      i=$((i+1))
      x=`echo $col6 | cut -d ',' -f $i`
    done
    if [ $i == 1 ]
    then
      echo $primer
    fi 
    #echo $x
    #str=$col6
    #awk -F',' '{ for(i=1;i<=NF;i++) print $i }' <<< $str
    #echo "$col1,$col2,$col3,$col4" >> outputfile.csv
done < $csvFile

