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
considereSL=0
searchIndideRPacket=0
declare -a results
declare -a directories
declare -a links
#---------------#
# End Variables
#---------------#


#-----------#
# Functions
#-----------#

#return element index from an array
# param1: value to search in the array
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
# param1 : directory path
function getAllDirectories(){
  if [ "$considereSL" = 1 ]; then
    directories=( $(find "$1" ! -path "$1" -type d) )
    links=( $(find "$1" ! -path "$1" -type l) )
    taille="${#directories[@]}"
    for link in "${links[@]}"
    do
        directories[$taille]="$link"
        ((taille++))
    done
  else
    directories=( $(find "$1" ! -path "$1" -type d) )
  fi
}

# get only the direct children directories from the directory
# param1 : directory path
function getDirectories(){
  if [ "$considereSL" = 1 ]; then
    directories=( $(find "$1" -maxdepth 1 ! -path "$1" -type d) )
    links=( $(find "$1" -maxdepth 1  ! -path "$1" -type l) )
    taille="${#directories[@]}"
    for link in "${links[@]}"
    do
        directories[$taille]="$link"
        ((taille++))
    done
  else
    directories=( $(find "$1" -maxdepth 1 ! -path "$1" -type d) )
  fi
}

#return total text line number from .r files in R folder
# param1: R packet main directory path
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
# param1: R packet main directory path
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
# param1: R packet main directory path
function getDataFileCount(){
   dir="$1/data" 
   if [ -d "$dir" ]; then
     allFiles=( $(find "$dir" -iregex '.*\(tab\|txt\|csv\|tab.gz\|tab.bz2\|tab.xz\|txt.bz2\|txt.xz\|txt.gz\|csv.gz\|csv.bz2\|csv.xz\)' -type f) )
     echo "${#allFiles[@]}"
   fi
}

#return number of files of a specific extension 
#param1 : directory path
#param2 : extension
function getFileCount(){
   dir="$1" 
   if [ -d "$dir" ]; then
     allFiles=( $(find "$dir" -iregex ".*\($2)" -type f) )
     echo "${#allFiles[@]}"
   fi
}

#check if the test folder exist and is not empty
# param1: R packet main directory path
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
# param1: directory path
# param2: file name
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
# param1: directory path
function getNumberFiles(){
  number=0
  if [ -d "$1" ]; then
    number=( $(find "$1" -type f | wc -l) )
  fi
  echo "$number"
}

#check if subfolder exist and if yes if it's not empty
# param1: directory path
function checkEmptyFolders(){
  emptyFolder=0
  # get all the folders in the folder
  for folder in "${folders[@]}"; do
    index=$(getArrayIndex "$folder")
    if [ -d "$1/$folder" ]; then
      fileCount=$(getNumberFiles "$1/$folder")
      if [ "$fileCount" = 0 ];then
         emptyFolder=1
      fi
    fi
  done
  echo "$emptyFolder"
}

#check if not folders are empty
# param1: directory path
function countFilesInFolders(){
  for folder in "${folders[@]}"; do
    index=$(getArrayIndex "$folder")
    if [ -d "$1/$folder" ]; then
      fileCount=$(getNumberFiles "$1/$folder")
      results[$index]="$fileCount"
    else
     results[$index]=0
    fi
  done
}

#check if it contains the mandatory files
#and if they are not empty.
# param1: directory path
function containsMandatoryFiles(){
  # get all the files in the folder
  containsMandatoryFiles=1
  for file in "${mandatoryFiles[@]}"; do
    if [ ! -s "$1/$file" ]; then
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
    countFilesInFolders "$1"
    results[0]="$1"
    results[1]=${1##*/} 
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
}

# process all the folders contained in the folder given as parameter
function processAllFolders(){
  getAllDirectories "$1"
  for dir in "${directories[@]}"; do
      isARPacket=$(containsMandatoryFiles "$dir")
      emptyFolder=$(checkEmptyFolders "$dir")
      if [ $isARPacket -eq 1 -a $emptyFolder -eq 0 ]; then
         processFolder "$dir"
      fi
  done
}

#process recursively directories contained by a directory if it is not a R packet
function processOneFolder(){
  getDirectories "$1"
  for dir in "${directories[@]}"; do
      isARPacket=$(containsMandatoryFiles "$dir")
      emptyFolder=$(checkEmptyFolders "$dir")
      if [ $isARPacket -eq 1 -a $emptyFolder -eq 0 ]; then
       processFolder "$dir"
      else
       processOneFolder "$dir"
      fi
  done
}

# print the package csv file
function print(){
  echo ${packageCSVFileStructure[@]} 
  cat package.csv
}

# print the help menu
function printHelp(){
  echo "Usage: ./rextract.sh [OPTION]..."
  echo ""
  echo "arguments"
  echo "  -L: Ignore symbolic link"
  echo "  -p: print package.csv file"
  echo "  -c: remove all files generated by the script"
  echo "  -r: specify to search also inside R packet"
  echo "  -d path: specify directory path"
  echo ""
}

#---------------#
# End Functions
#---------------#

# Choice selection
while getopts ":pchrLd:" opt; do
  case $opt in
    p)
      print
      exit 0
      ;;
    c)
      cleanResultFiles
      exit 0
      ;;
    L)
      considereSL=1
      ;;
    r)
      searchIndideRPacket=1
      ;;
    d)
      baseFolderPath=$OPTARG
      ;;
    h)
      printHelp
      exit 0
      ;;
    \?)
      echo "Invalid option: -$OPTARG" 
      printHelp
      exit 0
      ;;
  esac
done

if [ $searchIndideRPacket -eq 1 ]; then
 cleanResultFiles
 processAllFolders $baseFolderPath
else
 cleanResultFiles
 processOneFolder $baseFolderPath
fi
exit 0

