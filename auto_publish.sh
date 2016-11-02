#/usr/bini/bash

:<<BUILD
1.define useful value ;
2.run loop
3.process
BUILD

export PATH=./tools:$PATH;
CONFIG=/root/build-server/install_config
LOG_DIR=/root/build-server/log/
FLAG=no_update_packing
AUTO_INSTALL_NUM=`grep "ID" $CONFIG | wc -l`
echo $AUTO_INSTALL_NUM
SERVER_IP=10.239.52.50
NFS_CHECK_PATH=/home/share/handshake

run_loop(){
AUTO_TIMES=1
CONFIG=$1
AUTO_INSTALL_NUM=`grep "ID" $CONFIG | wc -l`
while [ $AUTO_TIMES -le $AUTO_INSTALL_NUM ]; do
	HOST=`grep -A5 ID$AUTO_TIMES  $CONFIG | grep HOST |cut -d "=" -f 2`
	USER=`grep -A5 ID$AUTO_TIMES $CONFIG | grep USER | cut -d "=" -f 2`
	PASSWD=`grep -A5 ID$AUTO_TIMES $CONFIG | grep PASSWORD | cut -d "=" -f 2`
	INSTALL_ENV=`grep -A5 ID$AUTO_TIMES $CONFIG | grep install_env | cut -d "=" -f 2`
	echo $HOST $USER $PASSWD $INSTALL_ENV
	if [ -e $LOG_DIR$FLAG ]; then
		echo "No update today!"
		exit 0
	else
		sleep 35
		echo 'ssh_command.py' $HOST $USER $PASSWD '"./vgt-get install '$INSTALL_ENV '>> /tmp/vgt.log"'
		ssh_command.py $HOST $USER $PASSWD "./vgt-get install $INSTALL_ENV >> /tmp/vgt.log"
		echo $AUTO_TIMES
	        ((AUTO_TIMES++)) 
		sleep 55
	fi
done
}

echo `expr $HANDSHAKE + 1`
case $1 in
staging)
echo staging
run_loop HSW-MOB-DP-STAGING-A
#run_loop HSW-ULT-HDMI-STAGING
#run_loop HSW-DESK-HDMI-STAGING
#run_loop HSW-MOB-DP-STAGING-B
#run_loop HSW-MOB-VGA-STAGING
;;

master)
echo master
#run_loop HSW-MOB-DP-MASTER-A
run_loop HSW-ULT-HDMI-MASTER
#run_loop HSW-DESK-HDMI-MASTER
#run_loop HSW-MOB-DP-MASTER-B
run_loop HSW-MOB-VGA-MASTER
esac
