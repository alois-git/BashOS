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
  tab=$1
  seeking=$2
  in=0
  for element in "${tab[@]}"; do
    if [[ "$element" == "$seeking" ]]; then
      in=1
      break
    fi
  done
  return $in
}

#check if subfolder exist and if yes if it's not empty
function checkFoldersNotEmpty(){
  echo "check folder empty $1"
  # get all the folders in the folder
  for folder in "${folders[@]}"; do
    index=$(getArrayIndex "$folder")
    if [ -d "$folder" ]; then
      fileCount=getNumberFiles "$folder"
      if [[ $fileCount -lt 1 ]]; then
 	echo "$folder is empty"
      else
       results[$index]=fileCount
      fi
    else
     results[$index]=0
     echo "$folder doest not exist"
    fi
  done
}

#check if it contains the mandatory files in the main folder
function containsMandatoryFiles(){
  echo "check mandatory files $1"
  # get all the files in the folder
  allFiles=( $(find "$1" -maxdepth 1 -type f) )
  containsMandatoryFiles=1
  for file in "${mandatoryFiles[@]}"; do
    containsMandatoryFiles=$(arrayContains "$allFiles" "$file")
  done

  if [ "$containsMandatoryFiles" = 1 ] ; then
    echo 'all mandatory files are present'
  else
    echo 'mandatory files missing'
  fi
}

function getNumberFiles(){
  return "$(ls $1 -l | grep ^- | wc -l)"
}

function writePackageCSVFile(){
  echo 'write package CSV file'
  line=""
  for folder in "${packageCSVFileStructure[@]}"; do
    index=$(getArrayIndex "$folder")
    echo ${results[$index]}
    if [[  ${results[$index]} != "" ]] ; then
        line+="${results[$index]};"
	echo "$line"
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
  containsMandatoryFiles "$1"
 
  checkFoldersNotEmpty "$1"

  writePackageCSVFile
}


# get all the directory
cleanResultFiles
getAllDirectories "$baseFolderPath"
echo "${directories[@]}"
# for each directory
for dir in "${directories[@]}"; do
  results[0]="$dir"
  results[1]=$(basename "$dir")
  echo " aaaaaaaaaaaaaaa : ${results[0]}"
  processFolder "$dir"
done
