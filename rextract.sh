#!/bin/bash

# Get folder path and name
baseFolderPath=$1
baseFolderName=$(basename "$folderPath")

packageFileName="package.csv"
# define the structure of a R packet
mandatoryFiles=('DESCRIPTION' 'NAMESPACE')
folders=("R" "data" "demo" "exec" "inst" "man" "po" "src" "tests" "tools" "vignettes")
optionalFiles=("INDEX" "configure" "cleanup" "LICENCE" "LICENSE" "NEWS")
declare -a results
declare -a directories
packageCSVFileStructure=("path" "name" "tests" "R" "R_size" "man" "src" "src_size" "demo" "data" "exec" "po" "tools" "inst"
"testsCount" "vignettes" "index")
results=("path" "name" "tests" "R" "R_size" "man" "src" "src_size" "demo" "data" "exec" "po" "tools" "inst"
"testsCount" "vignettes" "index")
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

#check if subfolder exist and if yes if it's not empty
function checkFoldersNotEmpty(){
  echo "check folder empty $1"
  # get all the folders in the folder
  for folder in "${folders[@]}"; do
    index=$(getArrayIndex "$folder")
    if [ -d "$1/$folder" ]; then
      fileCount=$(getNumberFiles "$1/$folder")
      echo "index :$index"
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

function cleanResultFiles(){
  if [ -f "$packageFileName" ]; then
   rm "$packageFileName"
  fi
}

#check if a folder is a R packet or not
function processFolder() {
  echo "Processing folder : ${results[0]}"
  isARPacket=$(containsMandatoryFiles "$1")
  if [ "$isARPacket" = 1 ]; then
    checkFoldersNotEmpty "$1"
    writePackageCSVFile
  fi
  echo "-------------------------------------"
  echo "-------------------------------------"
}


# get all the directory
cleanResultFiles
getAllDirectories "$baseFolderPath"
# for each directory
for dir in "${directories[@]}"; do
  results[0]="$dir"
  results[1]=$(basename "$dir")
  processFolder "$dir"
done
