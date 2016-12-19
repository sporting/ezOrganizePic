#!/bin/bash

# check input parameters exists
if [ -z "$1" ]; then
  printf 'please enter 1 input arguments: pic folder';
  exit;
fi

#second argument means backup pictures or not (default 1:yes)
if [ -z "$2" ]; then
  backupFlag="1"
else
  backupFlag="$2"
fi

searchFolder=$1
jpgList=$searchFolder'/jpg.lst'
folderList=$searchFolder'/folder.lst'
mvList=$searchFolder'/mv.lst'
backupFolder=$searchFolder'/backup'

rm $jpgList
rm $folderList
rm $mvList

find $searchFolder -maxdepth 1 -type f -name '*.JPG' >> $jpgList
find $searchFolder -maxdepth 1 -type f -name '*.jpg' >> $jpgList

#extract jpg filename to fullfilename@filename@datetime
cat $jpgList | while read x;do echo $x"@""${x##*/}""@"$(jhead $x |grep  Date/Time| cut -c -25 |awk -F ':' '{print $2$3$4}'|tr -d [:blank:]) >> $folderList; done

#mkdir
awk -F '@' '{print $3}' $folderList |sed '/^$/d' |sort|uniq | while read x;do mkdir $x;done 

if [ $backupFlag -eq "1" ]; then
	#clone jpg files to backup folder
	mkdir $backupFolder
	awk -F '@' '{print ($3 != "")? $1"@"$2"@"$3 : ""}' $folderList|sed '/^$/d' |while read x; do cp $(echo $x|awk -F '@' '{print $1}') $backupFolder/$(echo $x|awk -F '@' '{print $2}'); done
fi

#mv jpg files to date folder
awk -F '@' '{print ($3 != "")? $1"@"$2"@"$3 : ""}' $folderList|sed '/^$/d' |while read x; do mv $(echo $x|awk -F '@' '{print $1}') $(echo $x|awk -F '@' '{print $3"/"$2}'); done
