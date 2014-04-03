#!/bin/bash
#Variable setup
packageFileName="package.csv"
mandatoryFiles=('DESCRIPTION' 'NAMESPACE')
folders=("R" "data" "demo" "exec" "inst" "man" "po" "src" "tests" "tools" "vignettes")
optionalFiles=("INDEX" "configure" "cleanup" "LICENCE" "LICENSE" "NEWS")
declare -a results
declare -a directories
packageCSVFileStructure=("path" "name" "testsYN" "R" "R_size" "man" "src" "src_size" "demo" "data" "exec" "po" "tools" "inst"
"tests" "vignettes" "index" "licence" "license" "news")
results=("path" "name" "tests" "R" "R_size" "man" "src" "src_size" "demo" "data" "exec" "po" "tools" "inst"
"testsCount" "vignettes" "index" "licence" "license" "news")
isARPacket=0

#functions
function getArrayIndex(){
value=$1
for (( i = 0; i < ${#packageCSVFileStructure[@]}; i++ )); do
   if [ "${packageCSVFileStructure[$i]}" = "${value}" ]; then
       echo $i;
   fi
done
}

#get all directory of a directory except current dir and hidden dir
#recursive
function getAllDirectories(){
  directories=( $(find "$1" ! -path '*/\.*' ! -path "$1"  -type d) )
}

#check if a variable is in a array
function arrayContains(){ 
  declare -a tab=("${!1}")
  seeking=$2
  in=0
  for element in "${tab[@]}"; do
    if [ "$element" == "$seeking" ]; then
      in=1
      break
    fi
  done
  echo $in
}
#get total text line number from .r files in R folder
function getRSize(){
  count=0
  if [ -d "$1/R" ]; then
    allFiles=( $(find "$1/R" -iregex '.*\(R\)' -type f) )
    for file in "${allFiles[@]}"; do
      c=$(cat "$file" | wc -l)
      count=$(($count+$c))
    done
  fi
  echo "$count"
}
#get total text line number from text files in src folder
function getSrcSize(){
  count=0
  dir="$1/src" 
  if [ -d "$dir" ]; then
    allFiles=( $(find "$dir" -type f) )
    for file in "${allFiles[@]}"; do
      c=$(cat "$file" | wc -l)
      count=$(($count+$c))
    done
  fi
  echo "$count"
}

function getDataFileCount(){
   dir="$1/data" 
   if [ -d "$dir" ]; then
     allFiles=( $(find "$dir" -iregex '.*\(tab\|txt\|csv\tab.gz\tab.bz2\tab.xz\txt.bz2\txt.xz\txt.gz\csv.gz\csv.bz2\csv.xz\)' -type f) )
     echo "${#allFiles[@]}"
   fi
}

#get the file count with specific extension
#param1 : folder
#param2 : extension
function getFileCount(){
   dir="$1" 
   if [ -d "$dir" ]; then
     allFiles=( $(find "$dir" -iregex ".*\($2\)" -type f) )
     echo "${#allFiles[@]}"
   fi
}

function checkTestFolderExist(){
  if [[ -d "$1/tests" ]]; then
   fileCount=$(getNumberFiles "$1/tests")
   if [[ $fileCount -gt 0 ]]; then
     echo "y"
   else
     echo "n"
   fi
  else
   echo "n"
  fi
}

function checkFileExistAndNotEmpty(){
  file="$1/$2"
  if [[ -f "$file" ]]; then
   count=$(cat "$file" | wc -l)
   if [[ $count -gt 0 ]]; then
     echo "y"
   else
     echo "n"
   fi
  else
   echo "n"
  fi
}

#check if subfolder exist and if yes if it's not empty
function checkFoldersNotEmpty(){
  echo "check folder empty $1"
  # get all the folders in the folder
  for folder in "${folders[@]}"; do
    index=$(getArrayIndex "$folder")
    if [ -d "$1/$folder" ]; then
      fileCount=$(getNumberFiles "$1/$folder")
      if [[ $fileCount -gt 0 ]]; then
 	 results[$index]=$fileCount
      fi
    else
     results[$index]=0
    fi
  done
}

#check if it contains the mandatory files in the main folder
function containsMandatoryFiles(){
  # get all the files in the folder
  allFiles=( $(find "$1" -maxdepth 1 -type f) )
  containsMandatoryFiles=1
  for file in "${mandatoryFiles[@]}"; do
    containsMandatoryFiles=$(arrayContains allFiles[@] "$1/$file")
  done
  echo $containsMandatoryFiles
}

function getNumberFiles(){
  echo "$(ls $1 -l | grep ^- | wc -l)"
}

function writePackageCSVFile(){
  echo 'write package CSV file'
  line=""
  for folder in "${packageCSVFileStructure[@]}"; do
    index=$(getArrayIndex "$folder")
    if [[  ${results[$index]} != "" ]] ; then
        line+="${results[$index]};"
    fi
  done
  echo "$line" >> "$packageFileName"
}

function writeInstFile(){
  echo 'write inst file'
  InstFileName="${results[1]}.inst"
  line=""
  dir="$1/inst"
  if [ -d "$dir" ]; then
    allFiles=( $(find "$dir" -type f) )
    for file in "${allFiles[@]}"; do
      line=$(basename "$file")
      echo "$line" >> "$InstFileName"
    done
  else
    touch "$InstFileName"
  fi
}

function writeDSCFile(){
  DSCFileName="${results[1]}.dsc"
  line=$(head -n 1 "$1/DESCRIPTION")
  stringReplace=,
  line="${line/:/$stringReplace}"
  line="${line/ /}"
  echo "$line" >> "$DSCFileName"
}

#delete all the files before starting
function cleanResultFiles(){
  if [ -f "$packageFileName" ]; then
   rm "$packageFileName"
  fi
  rm *.inst
  rm *.dsc
}

#check if a folder is a R packet or not
function processFolder() {
  echo "Processing folder : ${results[0]}"
  isARPacket=$(containsMandatoryFiles "$1")
  if [ "$isARPacket" = 1 ]; then
    checkFoldersNotEmpty "$1"
    results[2]=$(checkTestFolderExist "$1")
    results[7]=$(getSrcSize "$1")
    results[4]=$(getRSize "$1") 

    results[3]=$(getFileCount "$1/R" "R")
    results[5]=$(getFileCount "$1/man" "Rd") 
    results[11]=$(getFileCount "$1/exec" "po") 
    results[9]=$(getFileCount "$1/data" ".tab")
    results[16]=$(checkFileExistAndNotEmpty "$1" "INDEX")
    results[17]=$(checkFileExistAndNotEmpty "$1" "LICENCE")
    results[18]=$(checkFileExistAndNotEmpty "$1" "LICENSE")
    results[19]=$(checkFileExistAndNotEmpty "$1" "NEWS")
    writePackageCSVFile
    writeInstFile "$1"
    writeDSCFile  "$1"
  fi
  echo "-------------------------------------"
  echo "-------------------------------------"
}

# Main function
function processAllFolders(){
  # get all the directory
  cleanResultFiles
  getAllDirectories "$baseFolderPath"
  # for each directory
  for dir in "${directories[@]}"; do
    results[0]="$dir"
    results[1]=$(basename "$dir")
    processFolder "$dir"
  done
}

function print(){
  echo ${packageCSVFileStructure[@]} 
  cat package.csv
}

# Choice selection
if [ $1 = "print" ]; then
  print
else
 baseFolderPath=$1
 baseFolderName=$(basename "$folderPath")
 processAllFolders
fi


