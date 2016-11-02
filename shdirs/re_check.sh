#!/bin/bash
log_path=/root/build-server/log
commit_log_file=$log_path/commit_id.log
update_flag_file=$log_path/no_update_packing
last_build_time=`cat $commit_log_file|tail -n 1| awk '{printf $3}'`
date=`date +%Y/%m/%d`
echo $last_build_time
echo $date
if [ $last_build_time = $date ];then
	echo "yes"
	rm -rf $update_flag_file
	cd /build_server/repos/kernel_xen_staging/
	git checkout staging
else
	echo "no"
	touch $update_flag_file
fi
