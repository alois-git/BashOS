#!/bin/bash
#title           :rextract.sh
#description     :Detect R packet folder and write their characteristics in files.
#author		 :Alois paulus
#date            :04/04/2014
#usage		 :bash rextract.sh
#==============================================================================

#----------#
# Variables
#----------#
packageFileName="package.csv"
mandatoryFiles=('DESCRIPTION' 'NAMESPACE')
folders=("R" "data" "demo" "exec" "inst" "man" "po" "src" "tests" "tools" "vignettes")
optionalFiles=("INDEX" "configure" "cleanup" "LICENCE" "LICENSE" "NEWS")
packageCSVFileStructure=("path" "name" "testsYN" "R" "R_size" "man" "src" "src_size" "demo" "data" "exec" "po" "tools" "inst"
"tests" "vignettes" "index" "licence" "license" "news")
results=("path" "name" "testsYN" "R" "R_size" "man" "src" "src_size" "demo" "data" "exec" "po" "tools" "inst"
"tests" "vignettes" "index" "licence" "license" "news")
isARPacket=0
declare -a results
declare -a directories
#---------------#
# End Variables
#---------------#


#-----------#
# Functions
#-----------#

#return element index from an array
function getArrayIndex(){
value=$1
for (( i = 0; i < ${#packageCSVFileStructure[@]}; i++ )); do
   if [ "${packageCSVFileStructure[$i]}" = "${value}" ]; then
       echo $i;
   fi
done
}

#get all directories from a directory except current dir and hidden dir
#recursive
function getAllDirectories(){
  directories=( $(find "$1" ! -path '*/\.*' ! -path "$1"  -type d) )
}

#return total text line number from .r files in R folder
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

#return total text line number from text files in src folder
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

#return number of file in the data directory
function getDataFileCount(){
   dir="$1/data" 
   if [ -d "$dir" ]; then
     allFiles=( $(find "$dir" -iregex '.*\(tab\|txt\|csv\|tab.gz\|tab.bz2\|tab.xz\|txt.bz2\|txt.xz\|txt.gz\|csv.gz\|csv.bz2\|csv.xz\)' -type f) )
     echo "${#allFiles[@]}"
   fi
}

#return number of files of a specific extension 
#param1 : folder
#param2 : extension
function getFileCount(){
   dir="$1" 
   if [ -d "$dir" ]; then
     allFiles=( $(find "$dir" -iregex ".*\($2)" -type f) )
     echo "${#allFiles[@]}"
   fi
}

#check if the test folder exist and is not empty
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

#check if a file exist and is not empty
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

#return the number of files in a directory
function getNumberFiles(){
  number=0
  if [ -d "$1" ]; then
    number=( $(find "$1" -type f | wc -l) )
  fi
  echo "$number"
}

#check if subfolder exist and if yes if it's not empty
function checkFolders(){
  # get all the folders in the folder
  for folder in "${folders[@]}"; do
    index=$(getArrayIndex "$folder")
    if [ -d "$1/$folder" ]; then
      fileCount=$(getNumberFiles "$1/$folder")
      results[$index]=$fileCount
    else
     results[$index]=0
    fi
  done
}

#check if it contains the mandatory files
#this function is use to check if a folder is a R packet or not
function containsMandatoryFiles(){
  # get all the files in the folder
  containsMandatoryFiles=1
  for file in "${mandatoryFiles[@]}"; do
    if [ ! -f "$1/$file" ]; then
      containsMandatoryFiles=0
    fi
  done
  echo $containsMandatoryFiles
}

#write csv file
function writePackageCSVFile(){
  #echo 'Writing in package.csv'
  line=""
  for folder in "${packageCSVFileStructure[@]}"; do
    index=$(getArrayIndex "$folder")
    if [[  ${results[$index]} != "" ]] ; then
        line+="${results[$index]};"
    fi
  done
  echo "$line" >> "$packageFileName"
}

#write the .inst file containing all the files from the inst folder.
function writeInstFile(){
  #echo 'Writing inst file'
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

#write the dsc file containing information from DESCRIPTION
function writeDSCFile(){
  #echo 'Writing dsc file'
  DSCFileName="${results[1]}.dsc"
  line=$(head -n 1 "$1/DESCRIPTION")
  stringReplace=,
  line="${line/:/$stringReplace}"
  line="${line/ /}"
  echo "$line" >> "$DSCFileName"
}

#delete all the files generated by a previous launch
function cleanResultFiles(){
  if [ -f "$packageFileName" ]; then
   rm "$packageFileName"
  fi
  rm *.inst > /dev/null 2>&1
  rm *.dsc > /dev/null 2>&1
}

#Process one folder
#check if the folder is a R packet or not
#if yes get all the informations and write them to files.
function processFolder() {

  #check if it is a R packet or not
  isARPacket=$(containsMandatoryFiles "$1")
  if [ "$isARPacket" = 1 ]; then
    checkFolders "$1"
    results[2]=$(checkTestFolderExist "$1")
    results[7]=$(getSrcSize "$1")
    results[4]=$(getRSize "$1") 

    results[3]=$(getFileCount "$1/R" 'R\')
    results[5]=$(getFileCount "$1/man" 'Rd\') 
    results[11]=$(getFileCount "$1/exec" 'po') 
    results[9]=$(getFileCount "$1/data" 'tab\')
    results[16]=$(checkFileExistAndNotEmpty "$1" "INDEX")
    results[17]=$(checkFileExistAndNotEmpty "$1" "LICENCE")
    results[18]=$(checkFileExistAndNotEmpty "$1" "LICENSE")
    results[19]=$(checkFileExistAndNotEmpty "$1" "NEWS")
    writePackageCSVFile
    writeInstFile "$1"
    writeDSCFile  "$1"
  fi
}

# Main function
# process all the folders contained in the folder
# given as parameter
function processAllFolders(){
  # get all the directory
  cleanResultFiles
  getAllDirectories "$baseFolderPath"
  # for each directory
  for dir in "${directories[@]}"; do
    results[0]="$dir"
    results[1]=${dir##*/} 
    #results[1]=$(basename "$dir")
    processFolder "$dir"
  done
}

# print the package csv file
function print(){
  echo ${packageCSVFileStructure[@]} 
  cat package.csv
}

# print the help menu
function printHelp(){
  echo "Usage: ./rextract.sh [OPTION]"
  echo ""
  echo "  print : print package.csv file"
  echo "  clean : remove all files generated by the script"
  echo "  dir : execute the script on the target directory"
  echo ""
}

#---------------#
# End Functions
#---------------#

# Choice selection
# Print to print package.csv
# Clean to remove all files generated by the script
if [ $# -eq 0 ]
  then
    printHelp
elif [ "$1" = "print" ]; then
  print
elif [ "$1" = "clean" ]; then
  cleanResultFiles
elif [ "$1" = "--help" ]; then
  printHelp
else
 baseFolderPath=$1
 processAllFolders
fi


