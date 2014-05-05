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
packageCSVFileStructure=("path" "name" "testsYN" "R" "R_size" "man" "src" "src_size" "demo" "data" "exec" "po" "tools" "inst"
"tests" "vignettes" "index" "licence" "license" "news")
results=("path" "name" "testsYN" "R" "R_size" "man" "src" "src_size" "demo" "data" "exec" "po" "tools" "inst"
"tests" "vignettes" "index" "licence" "license" "news")
isARPacket=0
ignoreSL=0
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

#get all directories containing mandatoryFiles 
# param1 : directory path
function getAllDirectories(){
  declare -a directoriesTemp
  maxdepth=""
  if [ $2 -eq 1 ];then
    maxdepth="-maxdepth 1"
  fi
  taille=0
  if [ "$ignoreSL" = 0 ]; then
    directoriesTemp=( $(find "$1" $maxdepth ! -path "$1" -type d -exec test -e "{}/DESCRIPTION" \; -exec test -e "{}/NAMESPACE" \; -print) )
    links=( $(find "$1" $maxdepth ! -path "$1" -type l -exec test -e "{}/DESCRIPTION" \; -exec test -e "{}/NAMESPACE" \; -print) )
    for link in "${links[@]}"
    do
        description=$(( find "$link" -name "DESCRIPTION" ! -empty) | wc -l)
        namespace=$(( find "$link" -name "NAMESPACE" ! -empty) | wc -l)
        if [ $description -gt 0 -a $namespace -gt 0 ];then
          directories[$taille]="$link"
          ((taille++))
        fi
    done
  else
    directoriesTemp=( $(find "$1" $maxdepth ! -path "$1" -type d -exec test -e "{}/DESCRIPTION" \; -exec test -e "{}/NAMESPACE" \; -print)  )
  fi

  for dir in "${directoriesTemp[@]}"
  do
        description=$(( find "$dir" -name "DESCRIPTION" ! -empty) | wc -l)
        namespace=$(( find "$dir" -name "NAMESPACE" ! -empty) | wc -l)
        if [ $description -gt 0 -a $namespace -gt 0 ];then
          directories[$taille]="$dir"
          ((taille++))
        fi
  done
}

#return total text line number from .r files in R folder
# param1: R packet main directory path
function getRSize(){
  count=0
  if [ -d "$1/R" ]; then
    count=$(( find "$1/R" -iregex '.*\(R\)' -type f -print0 | xargs -0 cat ) | wc -l)
  fi
  echo "$count"
}

#return total text line number from text files in src folder
# param1: R packet main directory path
function getSrcSize(){
  count=0
  dir="$1/src"
  if [ -d "$dir" ]; then
    count=$(( find "$dir" -type f -print0 | xargs -0 cat ) | wc -l)
  fi
  echo "$count"
}

#return number of files of a specific extension 
#param1 : directory path
#param2 : extension
function getFileCount(){
   dir="$1" 
   if [ -d "$dir" ]; then
     echo $(( find "$dir" -iregex ".*\($2)" -type f ) | wc -l)
   else
     echo 0
   fi
}

#check if the test folder exist and is not empty
# param1: R packet main directory path
function checkTestFolderExist(){
   fileCount=$(getNumberFiles "$1/tests")
   if [[ $fileCount -gt 0 ]]; then
     echo "y"
   else
     echo "n"
   fi
}

#check if a file exist and is not empty
# param1: directory path
# param2: file name
function checkFileExistAndNotEmpty(){
  file="$1/$2"
  if [[ -s "$file" ]]; then
   echo "y"
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
  for folder in "${folders[@]}"; do
    if [ -d "$1/$folder" ]; then
      fileCount=$(getNumberFiles "$1/$folder")
      if [ $fileCount -eq 0 ]; then
         emptyFolder=1
      fi
    fi
  done
  echo "$emptyFolder"
}

#count the number of file for all the folders
# param1: directory path
function countFilesInFolders(){
  for folder in "${folders[@]}"; do
    index=$(getArrayIndex "$folder")
    fileCount=$(getNumberFiles "$1/$folder")
    results[$index]="$fileCount"
  done
}

#write csv file
function writePackageCSVFile(){
  #echo 'Writing in package.csv'
  line=""
  for folder in "${packageCSVFileStructure[@]}"; do
    index=$(getArrayIndex "$folder")
    line+="${results[$index]};"
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
    find "$dir" -type f -printf "%f\n" >> "$InstFileName"
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
    results[4]=$(getRSize "$1") 
    results[3]=$(getFileCount "$1/R" 'R\')
    results[5]=$(getFileCount "$1/man" 'Rd\') 
    results[7]=$(getSrcSize "$1")
    results[9]=$(getFileCount "$1/data" 'tab\|txt\|csv\|tab.gz\|tab.bz2\|tab.xz\|txt.bz2\|txt.xz\|txt.gz\|csv.gz\|csv.bz2\|csv.xz\')
    results[11]=$(getFileCount "$1/exec" 'po\') 
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
  getAllDirectories "$1" 0
  for dir in "${directories[@]}"; do
      emptyFolder=$(checkEmptyFolders "$dir")
      if [ $emptyFolder -eq 0 ]; then
         processFolder "$dir"
      fi
  done
}

#process recursively directories contained by a directory if it is not a R packet
function processOneFolder(){
  getAllDirectories "$1" 1
  for dir in "${directories[@]}"; do
      emptyFolder=$(checkEmptyFolders "$dir")
      if [ $emptyFolder -eq 0 ]; then
       processFolder "$dir"
      else
       processOneFolder "$dir"
      fi
  done
}

# print the package csv file
function print(){
  if [ -f package.csv ];then
   echo ${packageCSVFileStructure[@]} 
   cat package.csv
  else
   echo "This folder does not contains package.csv"
  fi
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
      ignoreSL=1
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

if [[ ! "$baseFolderPath" = /* ]]; then
   baseFolderPath="$PWD/$baseFolderPath"
fi

if [ $searchIndideRPacket -eq 1 ]; then
 cleanResultFiles
 processOneFolder $baseFolderPath
else
 cleanResultFiles
 processAllFolders $baseFolderPath
fi
exit 0

