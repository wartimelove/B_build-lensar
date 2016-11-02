#!/bin/bash

FILE=$1
FILE_FLAG=`echo $FILE|sed 's/.*\(...\)$/\1/'`
DATE=`date +%Y%m%d`

useage(){
        cat << EOF
Usage: check_md5.sh [ help | RPM name | DEB name]
EOF
exit 0

}

md5_sum(){
	CHECK_ID=1
	FILE_NUM=`cat list | wc -l`

	while [  $CHECK_ID -lt $FILE_NUM ]; do
		CHECK_FILE=`cat list | head -n $CHECK_ID | tail -n 1`
		echo $CHECK_FILE
        	md5sum $CHECK_FILE >> md5_$DATE.log
		((CHECK_ID++))
	done
}

rm -rf list.tmp list

case  $FILE_FLAG in
	"deb") 
        dpkg -c $FILE > list.tmp
	cut -c 50- list.tmp > list
	md5_sum
	;;

        "rpm") 
	rpm -qilp $FILE >list.tmp
	sed '1,12d' list.tmp > list
	md5_sum
	;;

	"elp")
	useage
	echo help
	;;
	
	"")
	echo "invalid parameter"
	useage
esac

