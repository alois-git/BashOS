#!/bin/bash
#title           :syracuse.sh
#description     :
#author		 :Alois paulus
#date            :04/04/2014
#usage		 :bash syracuse.sh
#==============================================================================
declare -a suiteNumbers

function syra(){
  number="$1"
  if [ $((number%2)) -eq 0 ]; then
    echo $(($number / 2))
  else
    echo $((($number * 3)+1))
  fi
}

function syraSuite(){
  number=$1
  i=0
  while [ "$number" -ne 1 ]; do
    number=$(syra "$number")
    suiteNumbers[$i]="$number"
    i=$((i+1))
  done
}

function generateDOT(){
  line=""
  count="${#suiteNumbers[@]}"
  i=1
  echo "digraph monGraph {"
  for number in "${suiteNumbers[@]}"; do
    if [ $i -lt $count ]; then
     line+="$number -> "
    else
     line+="$number;"
    fi
    i=$((i+1))
  done
  echo "$line"
  echo "}"
}

syraSuite $1
generateDOT
