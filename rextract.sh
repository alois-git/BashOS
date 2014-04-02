#!/bin/bash

# Get folder path and name
folderPath=$1
folderName=$(basename "$folderPath")

packageFileName="package.csv"
# define the structure of a R packet
mandatoryFiles=('DESCRIPTION' 'NAMESPACE')
folders=("R" "data" "demo" "exec" "inst" "man" "po" "src" "tests" "tools" "vignettes")
optionalFiles=("INDEX" "configure" "cleanup" "LICENCE" "LICENSE" "NEWS")
declare -a results
packageCSVFileStructure=("path" "name" "tests" "R" "R_size" "man" "src" "src_size" "demo" "data" "exec" "po" "tools" "inst"
"tests" "vignettes" "index")
results["path"]=$folderPath
results["name"]=$folderName
#functions

#check if a variable is in a array
function array_contains() { 
    local array="$1[@]"
    local seeking=$2
    local in=0
    for element in "${!array}"; do
      if [[ "$element" == "$seeking" ]]; then
        in=1
        break
      fi
    done
    return $in
}

#check if subfolder exist and if yes if it's not empty
function checkFoldersNotEmpty(){
  # get all the folders in the folder
  allFolders=$(find "$1" -maxdepth 1 -type d)
  results["tests"]=array_contains allFolders "./tests" 
  for folder in "${allFolders[@]}"; do
    if [ -d "$folder" ]; then
      fileCount=getNumberFiles "$folder"
      if [[ $fileCount -lt 1 ]]; then
 	echo "$folder is empty"
	break;
      else
       results["$folder"]=fileCount
      fi
    fi
  done
}

#check if it contains the mandatory files in the main folder
function containsMandatoryFiles(){
  # get all the files in the folder
  allFiles=$(find "$1" -maxdepth 1 -type f)
  containsMandatoryFiles=1
  for file in "${allFiles[@]}"; do
    containsMandatoryFiles=array_contains allFiles "$file"
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
  line="$folderPath,$folderName"
  for folder in "${folders[@]}"; do
    if [[ "$results[$folder]" -gt 0 ]] ; then
        line+=";$results[$folder]"
    fi
  done 
  echo "$folderPath;$folderName" >> "$packageFileName"
}

#check if a folder is a R packet or not
function processFolder() {
  containsMandatoryFiles "$1"
 
  checkFoldersNotEmpty "$1"

  writePackageCSVFile
}

# get all the directory
directories=$(find "$folderPath" -type d)

# for each directory
for i in "${directories[@]}"; do
  processFolder "$i"
done
