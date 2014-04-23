#!/bin/bash
#title           :syracuse.sh
#description     :
#author		 :Alois paulus
#date            :04/04/2014
#usage		 :bash syracuse.sh
#==============================================================================
declare -a suiteNumbers

#Take a integer N > 0 and return next integer
function syra(){
  number="$1"
  if [ $((number%2)) -eq 0 ]; then
    echo $(($number / 2))
  else
    echo $((($number * 3)+1))
  fi
}

#Create an array with the syracuse suite for one number
function syraSuite(){
  declare -a numberArray
  number=$1
  i=0
  while [ "$number" -ne 1 ]; do
    numberArray[$i]="$number"
    number=$(syra "$number")
    i=$((i+1))
  done
  i=$((i+1))
  numberArray[$i]="$number"
  echo "${numberArray[@]}"
}

function calculateSyraSuiteForNumbers(){
  count=$1
  for ((i=1; i<=count; i=i+1)); do 
    array=$(syraSuite $i)
    suiteNumbers[$i]="${array[@]}"
  done
}

#Generate DOT file with all the syracuse suite inside
function generateDOT(){
  echo "strict digraph monGraph {"
  line=""
  for number in "${suiteNumbers[@]}"; do
    line=$(generateDOTRow ${number[@]} )
    echo "$line"
  done
  echo "}" 
}
#Generate a row of the DOT file with on syracuse suite
function generateDOTRow(){
  line=""
  tab=($@)
  count="${#tab[@]}"	
  count=$(($count-1))
  for ((i=0; i<count; i=i+1)); do 
      line+=""${tab[$i]}" -> "
  done
  line+="1;"
  echo "$line"
}

calculateSyraSuiteForNumbers $1
generateDOT
