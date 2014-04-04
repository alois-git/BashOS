#!/bin/bash
#title           :syracuseGen.sh
#description     :
#author		 :Alois paulus
#date            :04/04/2014
#usage		 :bash syracuseGen.sh
#==============================================================================


function generate(){
  number=$1
  while [ "$number" -gt 0 ]; do
    commandDot=$(./syracuse.sh $number)
    dot -Tpng <(echo "$commandDot") -o "$number".png
    number=$((number-1))
  done
}

generate $1
