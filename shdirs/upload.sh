#!/bin/bash

:<<BUILD
1.define useful value;
2.get_commit_id;
3.update_flag;
4.process;
BUILD

#set +x
if [ "$2" = "--date" ];then
	DATE=$3
else
	DATE=`date +%Y/%m/%d`
fi

PRE_PATH=/build_server/repos
LOG_DIR=/root/build-server/log/
FLAG=no_update_packing

KERNEL_COMMIT_ID_BAK=`cat /root/build-server/log/commit_id.log | grep Linux | tail -n 1|cut -d ":" -f 2 | awk '{print $2}'`
XEN_COMMIT_ID_BAK=`cat /root/build-server/log/commit_id.log | grep Linux | tail -n 1|cut -d ":" -f 2 | awk '{print $3}'`
IOEMU_COMMIT_ID_BAK=`cat /root/build-server/log/commit_id.log | grep Linux | tail -n 1 |cut -d ":" -f 2 | awk '{print $4}'`
KERNEL_WIN8_COMMIT_ID_BAK=`cat /root/build-server/log/commit_id.log | grep Win | tail -n 1|cut -d ":" -f 2 | awk '{print $2}'`
XEN_WIN8_COMMIT_ID_BAK=`cat /root/build-server/log/commit_id.log | grep Win | tail -n 1|cut -d ":" -f 2 | awk '{print $3}'`
IOEMU_WIN8_COMMIT_ID_BAK=`cat /root/build-server/log/commit_id.log | grep Win | tail -n 1 |cut -d ":" -f 2 | awk '{print $4}'`

get_commit_id(){
	COMMAND="git log -1 --pretty=format:%H"
	case $1 in
	KERNEL_COMMIT_ID)
	KERNEL_COMMIT_ID=`$COMMAND|head -c 7`
	git log --pretty=oneline --abbrev-commit $KERNEL_COMMIT_ID_BAK..HEAD > /root/build-server/log/kernel_patch.txt
	echo $KERNEL_COMMIT_ID
	;;

	XEN_COMMIT_ID)
	XEN_COMMIT_ID=`$COMMAND|head -c 7`
	git log --pretty=oneline --abbrev-commit $XEN_COMMIT_ID_BAK..HEAD > /root/build-server/log/xen_patch.txt
	echo $XEN_COMMIT_ID
	;;
	
	IOEMU_COMMIT_ID)
	IOEMU_COMMIT_ID=`$COMMAND|head -c 7`
	git log --pretty=oneline --abbrev-commit $IOEMU_COMMIT_ID_BAK..HEAD > /root/build-server/log/qemu_patch.txt
	echo $IOEMU_COMMIT_ID
	;;

	KERNEL_FOR_WIN8_COMMIT_ID)
	KERNEL_FOR_WIN8_COMMIT_ID=`$COMMAND|head -c 7`
#	git log --pretty=oneline --abbrev-commit $KERNEL_WIN8_COMMIT_ID_BAK..HEAD > /root/build-server/log/kernel_for_win8_patch.txt
	echo $KERNEL_FOR_WIN8_COMMIT_ID
	;;

	XEN_FOR_WIN8_COMMIT_ID)
	XEN_FOR_WIN8_COMMIT_ID=`$COMMAND|head -c 7`
#	git log --pretty=oneline --abbrev-commit $XEN_WIN8_COMMIT_ID_BAK..HEAD > /root/build-server/log/xen_for_win8_patch.txt
	echo $XEN_FOR_WIN8_COMMIT_ID
	;;

	IOEMU_FOR_WIN8_COMMIT_ID)
	IOEMU_FOR_WIN8_COMMIT_ID=`$COMMAND|head -c 7`
#	git log --pretty=oneline --abbrev-commit $IOEMU_WIN8_COMMIT_ID_BAK..HEAD >> /root/build-server/log/qemu_for_win8_patch.txt
	echo $IOEMU_FOR_WIN8_COMMIT_ID
	esac
}

update_flag(){
	if [ -e $LOG_DIR$FLAG ]; then
		rm $LOG_DIR$FLAG
		echo "update flag ready!"
	fi
}
echo 1
update_flag
echo 2
if [ "$1" == "master" ];then
	POST_KERNEL_PATH=/kernel-xen-master/
	POST_XEN_PATH=/kernel-xen-master/xen-vgt/
	POST_QEMU_PATH=/kernel-xen-master/xen-vgt/tools/qemu-xen-dir/
	FULL_KERNEL_PATH=$PRE_PATH$POST_KERNEL_PATH
	FULL_XEN_PATH=$PRE_PATH$POST_XEN_PATH
	FULL_QEMU_PATH=$PRE_PATH$POST_QEMU_PATH
	BRANCH_ID=2
elif [ "$1" == "staging" ];then
	POST_KERNEL_PATH=/kernel-xen-staging/
	POST_XEN_PATH=/kernel-xen-staging/xen-vgt/
	POST_QEMU_PATH=/kernel-xen-staging/xen-vgt/tools/qemu-xen-dir/
	FULL_KERNEL_PATH=$PRE_PATH$POST_KERNEL_PATH
	FULL_XEN_PATH=$PRE_PATH$POST_XEN_PATH
	FULL_QEMU_PATH=$PRE_PATH$POST_QEMU_PATH
	BRANCH_ID=5
fi
echo $FULL_KERNEL_PATH $FULL_XEN_PATH $FULL_QEMU_PATH


if [ -e $FULL_KERNEL_PATH ];then
	cd $FULL_KERNEL_PATH
	get_commit_id KERNEL_COMMIT_ID
fi

if [ -e $FULL_XEN_PATH ];then
	cd $FULL_XEN_PATH
	get_commit_id XEN_COMMIT_ID
fi

if [ -e $FULL_QEMU_PATH ];then
	cd $FULL_QEMU_PATH
	get_commit_id IOEMU_COMMIT_ID
fi

if [ -e $PRE_PATH/win8-rpm/ ];then
	cd $PRE_PATH/win8-rpm/
	#git checkout windbg0802
	get_commit_id KERNEL_FOR_WIN8_COMMIT_ID
fi

if [ -e $PRE_PATH/xen-for-win8-rpm ];then
	cd $PRE_PATH/xen-for-win8-rpm/
	get_commit_id XEN_FOR_WIN8_COMMIT_ID
fi

if [ -e $PRE_PATH/xen-for-win8-rpm/tools/ioemu-remote/ ];then
	cd $PRE_PATH/xen-for-win8-rpm/tools/ioemu-remote/
	get_commit_id IOEMU_FOR_WIN8_COMMIT_ID
fi

echo 3
#echo $XEN_COMMIT_ID"+"$KERNEL_COMMIT_ID
if [  "$XEN_COMMIT_ID" == "$XEN_COMMIT_ID_BAK" ] && [ "$KERNEL_COMMIT_ID" == "$KERNEL_COMMIT_ID_BAK" ]; then
	if [ "$IOEMU_COMMIT_ID" == "$IOEMU_COMMIT_ID_BAK" ]; then
		touch $LOG_DIR$FLAG
		echo "No update today for linux.."
	else
		curl 'xenvgt.sh.intel.com/report/addversion.php?b='+$BRANCH_ID+'&d='+$DATE+'&k='+$KERNEL_COMMIT_ID+'&x='+$XEN_COMMIT_ID+'&q='+$IOEMU_COMMIT_ID
		echo "Linux build:" $DATE $KERNEL_COMMIT_ID $XEN_COMMIT_ID $IOEMU_COMMIT_ID | tee -a /root/build-server/log/commit_id.log
	fi
		
elif [ "$XEN_COMMIT_ID" == "$XEN_COMMIT_ID_BAK" ] && [ "$KERNEL_COMMIT_ID" != "$KERNEL_COMMIT_ID_BAK" ]; then
	curl 'xenvgt.sh.intel.com/report/addversion.php?b='+$BRANCH_ID+'&d='+$DATE+'&k='+$KERNEL_COMMIT_ID+'&x='+$XEN_COMMIT_ID+'&q='+$IOEMU_COMMIT_ID_BAK
	echo "Linux build:" $DATE $KERNEL_COMMIT_ID $XEN_COMMIT_ID $IOEMU_COMMIT_ID_BAK | tee -a /root/build-server/log/commit_id.log
else
	curl 'xenvgt.sh.intel.com/report/addversion.php?b='+$BRANCH_ID+'&d='+$DATE+'&k='+$KERNEL_COMMIT_ID+'&x='+$XEN_COMMIT_ID+'&q='+$IOEMU_COMMIT_ID
	echo "Linux build:" $DATE $KERNEL_COMMIT_ID $XEN_COMMIT_ID $IOEMU_COMMIT_ID | tee -a /root/build-server/log/commit_id.log
fi

if [ "$XEN_FOR_WIN8_COMMIT_ID" == "$XEN_WIN8_COMMIT_ID_BAK" ] && [ "$KERNEL_FOR_WIN8_COMMIT_ID" == "$KERNEL_WIN8_COMMIT_ID_BAK" ]; then
        touch $LOG_DIR$FLAG
	echo "No update today for win8.."
elif  [ "$XEN_FOR_WIN8_COMMIT_ID" == "$XEN_WIN8_COMMIT_ID_BAK" ] && [ "$KERNEL_FOR_WIN8_COMMIT_ID" != "$KERNEL_WIN8_COMMIT_ID_BAK" ]; then
#	curl 'xenvgt.sh.intel.com/report/addversion.php?b=4&d='+$DATE+'&k='+$KERNEL_FOR_WIN8_COMMIT_ID+'&x='+$XEN_FOR_WIN8_COMMIT_ID+'&q='+$IOEMU_WIN8_COMMIT_ID_BAK
	echo "Win8 build:"$DATE $KERNEL_FOR_WIN8_COMMIT_ID $XEN_FOR_WIN8_COMMIT_ID $IOEMU_WIN8_COMMIT_ID_BAK | tee -a /root/build-server/log/commit_id.log
else
#	curl 'xenvgt.sh.intel.com/report/addversion.php?b=4&d='+$DATE+'&k='+$KERNEL_FOR_WIN8_COMMIT_ID+'&x='+$XEN_FOR_WIN8_COMMIT_ID+'&q='+$IOEMU_FOR_WIN8_COMMIT_ID
	echo "Win8 build:"$DATE $KERNEL_FOR_WIN8_COMMIT_ID $XEN_FOR_WIN8_COMMIT_ID $IOEMU_FOR_WIN8_COMMIT_ID | tee -a /root/build-server/log/commit_id.log
fi

