#!/bin/bash
USER=vgt
PASSWORD=vgt_back
STORAGE_PATH=/build_server/
DEB_PATH=/build_server/deb/
DEB_MASTER_CHECK=`ls -all $DEB_PATH |grep deb | grep master | wc -l`
DEB_STAGING_CHECK=`ls -all $DEB_PATH | grep deb | grep staging | wc -l`

UBUNTU_FLAG=`cat /proc/version | grep Ubuntu | wc -l`
RED_HAT_FLAG=`cat /proc/version | grep 'Red Hat' | wc -l`
if [ "$UBUNTU_FLAG" == "1" ]; then
        BUILD_FLAG=deb
        echo $BUILD_FLAG
elif [ "$RED_HAT_FLAG" == "1" ]; then
        BUILD_FLAG=rpm
        echo $BUILD_FLAG
else
        echo "check system version,please"
fi

UPLOAD_FILE_PATH=/build_server/$BUILD_FLAG
UPLOAD_PATH=vt-nfs:/home/vgt/packages/$BUILD_FLAG/
URL=http://vt-nfs.sh.intel.com/vgt/$BUILD_FLAG/


curl  -s -I --connect-timeout 5 --max-time 10 $URL | grep -q "OK"
if [ $? -eq 0 ]; then
	echo "OK"
else 
	echo "false"
fi

#curl -d "user=vgt&password=vgt_back" http://vt-nfs.sh.intel.com/vgt/rpm/  -T test_upload
#curl -u "vgt:vgt_back" http://vt-nfs.sh.intel.com/vgt/rpm/  -T test_upload


#scp $STORAGE_PATH$BUILD_FLAG/*.$BUILD_FLAG  $USER@$UPLOAD_PATH << EOF
#vgt_back

#EOF
#mount vt-nfs:/home/vgt/packages/ /mnt/
if [  "$DEB_MASTER_CHECK"  == "1" ]; then
	echo "master"
	mount vt-nfs:/home/vgt/packages/ /mnt/
	cp $STORAGE_PATH$BUILD_FLAG/*.$BUILD_FLAG /mnt/master_$BUILD_FLAG
#	umount /mnt/
elif [ "$DEB_STAGING_CHECK" == "1" ]; then
	echo "staging"
	mount vt-nfs:/home/vgt/packages/ /mnt/
	cp $STORAGE_PATH$BUILD_FLAG/*.$BUILD_FLAG /mnt/staging_$BUILD_FLAG
#	umount /mnt/
else
	echo  "no deb build ready!"
	exit 0
fi
umount /mnt/
