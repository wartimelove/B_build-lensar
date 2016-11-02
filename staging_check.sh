#!/bin/bash

staging_path=/build_server/repos/kernel-xen-staging/
current_path=`pwd`

cd $staging_path
git checkout staging
git pull
new_commit_flag=`git log -1 --pretty=format:"%H" | head -c 7`
echo $new_commit_flag
cat /root/build-server/log/commit_id.log | grep $new_commit_flag 
if [ $? -eq 0  ];then
	echo $check_num
	echo "No new patch for staging branch!"
else
	rm -rf /build_server/out/kernel-xen-staging/*
	rm -rf /root/build-server/log/no_update_packing
fi
