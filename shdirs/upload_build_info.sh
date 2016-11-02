#!/bin/bash
USER=vmm
UPLOAD_PATH=vmm-qa:/home/vmm/vgt_data/raw_data/build
UBUNTU_FLAG=`cat /proc/version | grep Ubuntu | wc -l`
RED_HAT_FLAG=`cat /proc/version | grep 'Red Hat' | wc -l`
DEB_PATH=/build_server/deb/
DEB_MASTER_CHECK=`ls -all $DEB_PATH |grep deb | grep master | wc -l`
DEB_STAGING_CHECK=`ls -all $DEB_PATH | grep deb | grep staging | wc -l`

URL=http://vt-nfs.sh.intel.com/vgt/

if [ "$1" = "--date" ];then
	DATE=$2
else
	DATE=`date +%Y%m%d`
fi

if [ "$UBUNTU_FLAG" == "1" ]; then
	BUILD_FLAG=deb
	BUILD_INFO=hsw
	echo $BUILD_FLAG
elif [ "$RED_HAT_FLAG" == "1" ]; then
	BUILD_FLAG=rpm
	BUILD_INFO=snb
	echo $BUILD_FLAG
else
	echo "check system version,please"
fi

if [  "$DEB_MASTER_CHECK"  == "1" ]; then
	echo "master"
	build_kernel_path=/build_server/repos/kernel-xen-master/
	build_xen_path=/build_server/repos/kernel-xen-master/xen-vgt/
	build_qemu_path=/build_server/repos/kernel-xen-master/xen-vgt/tools/qemu-xen-dir/
elif [ "$DEB_STAGING_CHECK" == "1" ]; then
	echo "staging"
	build_kernel_path=/build_server/repos/kernel-xen-staging/
	build_xen_path=/build_server/repos/kernel-xen-staging/xen-vgt/
	build_qemu_path=/build_server/repos/kernel-xen-staging/xen-vgt/tools/qemu-xen-dir/
else
	echo  "no deb build ready!"
	exit 0
fi

build_date=$DATE
test_date=
branch=`cd $build_kernel_path; git branch | grep ^* | awk '{printf $2}'`
echo $branch | grep master
if [ $? = 0 ];then
	branch=master
else
	branch=staging
fi
build_date=$DATE
test_date=

kernel_version=`cd $build_kernel_path; git log -1  --pretty=format:"%H"|head -c 7`
xen_version=`cd $build_xen_path; git log -1  --pretty=format:"%H" | head -c 7`
qemu_version=`cd $build_qemu_path; git log -1  --pretty=format:"%H"| head -c 7`
pass=
fail=
total=
plf_name=$BUILD_INFO"-build"
rpm_url=
#http://vt-nfs.sh.intel.com/vgt/$BUILD_FLAG/kernel_xen-$kernel_version"_"$xen_version"_"$DATE"_3.7.0+-1.x86_64."rpm
if [ "$DEB_MASTER_CHECK" == "1" ]; then
	deb_url=http://vt-nfs.sh.intel.com/vgt/master_$BUILD_FLAG/kernel-xen-$branch-$kernel_version"-"$xen_version"-"$DATE"_1-1_amd64.deb"
elif [ "$DEB_STAGING_CHECK" == "1" ]; then
	deb_url=http://vt-nfs.sh.intel.com/vgt/staging_$BUILD_FLAG/kernel-xen-$branch-$kernel_version"-"$xen_version"-"$DATE"_1-1_amd64.deb"
else
	exit 0
fi
summary_url=

echo "build_date=$build_date" > $BUILD_FLAG"build_"$DATE.txt
echo "test_date=$test_date" >> $BUILD_FLAG"build_"$DATE.txt
echo "branch=$branch" >> $BUILD_FLAG"build_"$DATE.txt
echo "kernel_version=$kernel_version" >> $BUILD_FLAG"build_"$DATE.txt
echo "xen_version=$xen_version" >> $BUILD_FLAG"build_"$DATE.txt
echo "qemu_version=$qemu_version" >> $BUILD_FLAG"build_"$DATE.txt
echo "pass=$pass" >> $BUILD_FLAG"build_"$DATE.txt
echo "fail=$fail" >> $BUILD_FLAG"build_"$DATE.txt
echo "total=$total" >> $BUILD_FLAG"build_"$DATE.txt
echo "plf_name=$plf_name" >> $BUILD_FLAG"build_"$DATE.txt
echo "rpm_url=$rpm_url" >> $BUILD_FLAG"build_"$DATE.txt
echo "deb_url=$deb_url" >> $BUILD_FLAG"build_"$DATE.txt
echo "summary_url=$summary_url" >> $BUILD_FLAG"build_"$DATE.txt

CURRENT_PATH=`pwd`
UPLOAD_LOG_PATH=$CURRENT_PATH/$BUILD_FLAG"build_"$DATE.txt
UPLOAD_LOG=$BUILD_FLAG"build_"$DATE.txt

echo $UPLOAD_LOG

post_data build $UPLOAD_LOG
#scp $UPLOAD_LOG $USER@$UPLOAD_PATH << EOF
#123456

#EOF
