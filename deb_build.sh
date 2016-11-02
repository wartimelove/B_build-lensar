#!/bin/bash

CURRENT_PATH=`pwd`
NODE_NAME=`pwd | cut -d "/" -f 4`
BUILD_PATH="project/deb"
BUILD_COMMAND=dpkg-buildpackage
CONTROL_PATH="/root/workspace/build-server-etc/control"
SCRIPT_PATH="/root/workspace/build-server-etc/others"
DATE=`date +%Y%m%d`
DEB_PATH="/build_server/deb"
DEB_BACKUP_PATH="/build_server/deb/backup/kernel-xen"
SHELL_DIR="/root/build-server/shdirs"
Build_MAIL="ruipengx.li@intel.com"
CC_MAIL="chao.zhou@intel.com"

KERNEL_COMMIT_ID=`git log -1  --pretty=format:"%H"`
XEN_COMMIT_ID=`cd xen-unstable; git log -1  --pretty=format:"%H"`
QEMU_COMMIT_ID=`cd xen-unstable/tools/qemu-xen-dir; git log -1  --pretty=format:"%H"`

LAST_KERNEL_COMMIT_INFO=`git log -n 1 --oneline`
LAST_XEN_COMMIT_INFO=`cd xen-unstable; git log -n 1 --oneline`
LAST_QEMU_COMMIT_INFO=`cd xen-unstable/tools/qemu-xen-dir; git log -n 1 --oneline`

KERNEL_COMMIT_FLAG=`expr substr "$KERNEL_COMMIT_ID" 1 7`
XEN_COMMIT_FLAG=`expr substr "$XEN_COMMIT_ID" 1 7`
QEMU_COMMIT_FLAG=`expr substr "$QEMU_COMMIT_ID" 1 7`

DEB_NAME=$NODE_NAME"-"$KERNEL_COMMIT_FLAG"-"$XEN_COMMIT_FLAG"-"$DATE
echo "************************************************************************" > deb.info
echo "kernel commit id:"$KERNEL_COMMIT_ID >> deb.info
echo "xen commit id :"$XEN_COMMIT_ID >> deb.info
echo "qemu commit id :"$QEMU_COMMIT_ID >> deb.info
echo "build_date" :"$DATE" >> deb.info
echo "************************************************************************" >> deb.info
echo $DEB_NAME
DATE_STAMP=`date +%Y-%m-%d`
BRANCH=`git branch | grep ^* | awk '{printf $2}'`
INFO="Hi:\n\n
kernel commit id:$KERNEL_COMMIT_ID \n
last commit info:$LAST_KERNEL_COMMIT_INFO \n\n 
xen commit id:$XEN_COMMIT_ID \n
last commit info: $LAST_XEN_COMMIT_INFO \n\n
qemu commit id: $QEMU_COMMIT_ID \n
last commit info : $LAST_QEMU_COMMIT_INFO \n"
echo  -ne $INFO

init_env(){
	mkdir  -p $BUILD_PATH/$NODE_NAME"-1"
	cd $CURRENT_PATH/$BUILD_PATH
	tar cjvf $NODE_NAME"-1.tar.bz2" $NODE_NAME"-1"
}

build(){
	cd $CURRENT_PATH/$BUILD_PATH/$NODE_NAME"-1"
	dh_make -s \
	-e ruipeng.li@intel.com \
	-f ../$NODE_NAME"-1.tar.bz2" << EOF

EOF
	control
	postinst
	preinst
	postrm
	prerm
	$BUILD_COMMAND -rfakeroot
}

control(){
	case $NODE_NAME in
	vgt-kernel-deb)
	rm -rf debian/control
	cp -rf $CONTROL_PATH/$NODE_NAME".control" debian/control
	;;
	
	vgt-xen-deb)
	rm -rf debian/control
	cp -rf $CONTROL_PATH/$NODE_NAME".control" debian/control
	;;


	kernel-xen-staging)
	rm -rf debian/control
	cp -rf $CONTROL_PATH/$NODE_NAME".control" debian/control
	;;

	kernel-xen-master)
	rm -rf debian/control
	cp -rf $CONTROL_PATH/$NODE_NAME".control" debian/control
	esac
}

postinst(){
	case $NODE_NAME in
	vgt-kernel-deb)
	cp -rf $SCRIPT_PATH/$NODE_NAME".postinst" debian/
	;;
	
	vgt-xen-deb)
	cp -rf $SCRIPT_PATH/$NODE_NAME".postinst" debian/
	;;

	kernel-xen-staging)
	cp -rf $SCRIPT_PATH/$NODE_NAME".postinst" debian/
	;;

	kernel-xen-master)
	cp -rf $SCRIPT_PATH/$NODE_NAME".postinst" debian/
	esac
}

preinst(){
	case $NODE_NAME in
	vgt-kernel-deb)
	cp -rf $SCRIPT_PATH/$NODE_NAME".preinst" debian/
	;;

	vgt-xen-deb)
	cp -rf $SCRIPT_PATH/$NODE_NAME".preinst" debian/
	;;

	kernel-xen-staging)
	cp -rf $SCRIPT_PATH/$NODE_NAME".preinst" debian/
	;;

	kernel-xen-master)
	cp -rf $SCRIPT_PATH/$NODE_NAME".preinst" debian/
	esac
}

postrm(){
	case $NODE_NAME in
	vgt-kernel-deb)
	cp -rf $SCRIPT_PATH/$NODE_NAME".postrm" debian/
	;;

	vgt-xen-deb)
	cp -rf $SCRIPT_PATH/$NODE_NAME".postrm" debian/
	;;

	kernel-xen-staging)
	cp -rf $SCRIPT_PATH/$NODE_NAME".postrm" debian/
	;;

	kernel-xen-master)
	cp -rf $SCRIPT_PATH/$NODE_NAME".postrm" debian/
	esac
}

prerm(){
	case $NODE_NAME in
	vgt-kernel-deb)
	cp -rf $SCRIPT_PATH/$NODE_NAME".prerm" debian/
	;;

	vgt-xen-deb)
	cp -rf $SCRIPT_PATH/$NODE_NAME".prerm" debian/
	;;

	kernel-xen-staging)
	cp -rf $SCRIPT_PATH/$NODE_NAME".prerm" debian/
	;;

	kernel-xen-master)
	cp -rf $SCRIPT_PATH/$NODE_NAME".prerm" debian/
	esac
}


reset_source(){
	case $NODE_NAME in
	vgt-kernel-deb)
	mkdir -p boot/vgt/
	mkdir -p lib/modules/
	mkdir -p etc/udev/rules.d/
	cp -rf /lib/modules/3.11.6-vgt+ lib/modules/
	cp -rf $CURRENT_PATH/vgt.rules etc/udev/rules.d/; 
	cp -rf $CURRENT_PATH/arch/x86/boot/bzImage boot/vgt/dom0-vgt-3.11.6-vgt+
	cp -rf $CURRENT_PATH/config-3.11.6-dom0 boot/config-3.11.6-vgt+
	;;

	vgt-xen-deb)
	mkdir -p boot/vgt/
	mkdir -p etc/
	mkdir -p usr/
	mkdir -p var/
	cp $CURRENT_PATH/xen/xen.gz boot/vgt/xen-vgt.gz 
	cp -rf $CURRENT_PATH/dist/install/etc/* etc/
	cp -rf $CURRENT_PATH/dist/install/usr/* usr/ 
	cp -rf $CURRENT_PATH/dist/install/var/* var/
	;;


	kernel-xen-staging)
	mkdir -p boot/vgt/
	mkdir -p lib/modules/
	mkdir -p etc/udev/rules.d/
	mkdir -p etc/modprobe.d/
	mkdir -p etc/
	mkdir -p usr/
	mkdir -p var/
	cp -rf /lib/modules/3.11.6-vgt+ lib/modules/
	cp -rf $CURRENT_PATH/vgt.rules etc/udev/rules.d/; 
	#cp -rf $CURRENT_PATH/vgt.conf etc/modprobe.d/; 
	cp -rf $CURRENT_PATH/arch/x86/boot/bzImage boot/vgt/dom0-vgt-3.11.6-vgt+
	cp -rf $CURRENT_PATH/config-3.11.6-dom0 boot/config-3.11.6-vgt+
	cp $CURRENT_PATH/xen-unstable/xen/xen.gz boot/vgt/xen-vgt.gz 
	cp -rf $CURRENT_PATH/xen-unstable/dist/install/etc/* etc/
	cp -rf $CURRENT_PATH/xen-unstable/dist/install/usr/* usr/ 
	cp -rf $CURRENT_PATH/xen-unstable/dist/install/var/* var/
	cp -rf $CURRENT_PATH/vmlinux boot/vgt/
	cp -rf $CURRENT_PATH/deb.info var/log/
	;;

	kernel-xen-master)
	mkdir -p boot/vgt/
	mkdir -p lib/modules/
	mkdir -p etc/udev/rules.d/
	mkdir -p etc/modprobe.d/
	mkdir -p etc/
	mkdir -p usr/
	mkdir -p var/
	mkdir -p var/log/
	cp -rf /lib/modules/3.11.6-vgt+ lib/modules/
	cp -rf $CURRENT_PATH/vgt.rules etc/udev/rules.d/; 
	#cp -rf $CURRENT_PATH/vgt.conf etc/modprobe.d/; 
	cp -rf $CURRENT_PATH/arch/x86/boot/bzImage boot/vgt/dom0-vgt-3.11.6-vgt+
	cp -rf $CURRENT_PATH/config-3.11.6-dom0 boot/config-3.11.6-vgt+
	cp $CURRENT_PATH/xen-unstable/xen/xen.gz boot/vgt/xen-vgt.gz 
	cp -rf $CURRENT_PATH/xen-unstable/dist/install/etc/* etc/
	cp -rf $CURRENT_PATH/xen-unstable/dist/install/usr/* usr/ 
	cp -rf $CURRENT_PATH/xen-unstable/dist/install/var/* var/
	cp -rf $CURRENT_PATH/vmlinux boot/vgt/
	cp -rf $CURRENT_PATH/deb.info var/log/
	esac
}

rebuild(){
	cd $CURRENT_PATH/$BUILD_PATH/
	dpkg -X $NODE_NAME"_1-1_amd64.deb" $NODE_NAME"-build-1"
	cd $NODE_NAME"-build-1"
	dpkg -e ../$NODE_NAME"_1-1_amd64.deb"
	reset_source
	cd ../
	dpkg -b $NODE_NAME"-build-1" $DEB_NAME"_1-1_amd64.deb"
}

upload_info(){
	case $NODE_NAME in
	kernel-xen-master)
	DATE_NUM=`date +%u`
	if [ $DATE_NUM != "8" ];then
	if [ $# -eq 1 ];then
		$SHELL_DIR/upload.sh master --date $1
		$SHELL_DIR/rpm_deb_upload.sh
		$SHELL_DIR/upload_build_info.sh --date `echo $1 | sed 's/\///g'`
	else
		$SHELL_DIR/upload.sh master
		$SHELL_DIR/rpm_deb_upload.sh
		$SHELL_DIR/upload_build_info.sh
	fi
	fi
	;;
	
	kernel-xen-staging)
	if [ $# -eq 1 ];then
		$SHELL_DIR/upload.sh staging --date $1
		$SHELL_DIR/rpm_deb_upload.sh
		$SHELL_DIR/upload_build_info.sh --date `echo $1 | sed 's/\///g'`
	else
		$SHELL_DIR/upload.sh staging
		$SHELL_DIR/rpm_deb_upload.sh
		$SHELL_DIR/upload_build_info.sh
	fi
	esac
}

init_env
build
rebuild
cp $DEB_NAME"_1-1_amd64.deb" $CURRENT_PATH/
cd  $CURRENT_PATH/

mv  $DEB_PATH/*.deb $DEB_BACKUP_PATH/
cp  $DEB_NAME"_1-1_amd64.deb" $DEB_PATH/
if [  `date +%u` != "8" ] && [ $BRANCH == "master" ]; then 
	echo -ne $INFO | mutt -s "vgt-kernel-xen-$BRANCH build: $DATE_STAMP" $Build_MAIL -c $CC_MAIL
elif [ `date +%u` != "8" ] && [ $BRANCH == "staging" ];then
	echo -ne $INFO | mutt -s "vgt-kernel-xen-$BRANCH build: $DATE_STAMP" $Build_MAIL -c $CC_MAIL
else
	echo "not need  send mail!"
fi 
if [ "$1"  = "--date" ];then
	upload_info $2
else
	upload_info
fi
