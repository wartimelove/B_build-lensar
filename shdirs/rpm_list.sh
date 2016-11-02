#!/bin/bash

:<<\EOF
1.PATH list;
2.BRANCH info list;
3.RPM auto list;
EOF
RPM_PATH=/build_server/rpm
RPM_KERNEL_PATH=/build_server/rpm/kernel
RPM_XEN_PATH=/build_server/rpm/xen
RPM=`ls $RPM_PATH/|wc -w`



rpm_list(){
	KERNEL_FOR_WIN8_BRANCH=`cd /build_server/repos/win8-rpm ; git branch --merged | awk '{print $2}'`
	KERNEL_BRANCH=`cd /build_server/repos/vgt-linux-rpm ; git branch --merged | awk '{print $2}'`
	XEN_BRANCH=`cd /build_server/repos/vgt-xen-rpm ; git branch --merged | awk '{print $2}'`
	XEN_FOR_WIN8_BRANCH=`cd /build_server/repos/xen-for-win8-rpm ; git branch --merged | awk '{print $2}'`



        #RPM_NUM=$[$RPM-2]
        while [ $RPM -gt 0 ]; do
		RPM_NAME=`ls $RPM_PATH/ |head -n $RPM|tail -n 1`
		iif_RPM_NAME=`echo $RPM_NAME | grep rpm | wc -l`
		echo $RPM_NAME
		TIME_STAMP=`stat $RPM_PATH/$RPM_NAME | grep -i Modify | awk -F. '{print $1}' | awk '{print $2}' | awk -F- '{print $1$2$3}'`
        	KERNEL_CHECK=`file $RPM_PATH/$RPM_NAME | cut -d ":" -f 1|grep kernel|wc -l`
		XEN_CHECK=`file $RPM_PATH/$RPM_NAME | cut -d ":" -f 1|grep xen|wc -l`
		echo $KERNEL_CHECK
		echo $XEN_CHECK
		if [ $KERNEL_CHECK -ge 1 ] && [ $iif_RPM_NAME == 1 ];then
			WIN8_CHECK=`file $RPM_PATH/$RPM_NAME.rpm | cut -d ":" -f 1|grep win8|wc -l`
			if [ $WIN8_CHECK -ge 1 ];then
				mkdir -p $RPM_KERNEL_PATH/$TIME_STAMP-$KERNEL_FOR_WIN8_BRANCH
				cp -rf $RPM_PATH/vgt_kernel_win8*.rpm $RPM_KERNEL_PATH/$TIME_STAMP-$KERNEL_FOR_WIN8_BRANCH/
				cp -rf /root/build-server/log/kernel_for_win8_patch.txt $RPM_KERNEL_PATH/$TIME_STAMP-$KERNEL_FOR_WIN8_BRANCH/
				rm -rf $RPM_PATH/vgt_kernel_win8*.rpm
			else
		        	mkdir -p $RPM_KERNEL_PATH/$TIME_STAMP-$KERNEL_BRANCH
                		cp -rf $RPM_PATH/vgt_kernel-*.rpm $RPM_KERNEL_PATH/$TIME_STAMP-$KERNEL_BRANCH/
				cp -rf /root/build-server/log/kernel_patch.txt $RPM_KERNEL_PATH/$TIME_STAMP-$KERNEL_BRANCH/
                		rm -rf $RPM_PATH/vgt_kernel-*.rpm
			fi
		elif [ $XEN_CHECK -ge 1 ] && [ $iif_RPM_NAME == 1 ]; then
			WIN8_CHECK=`file $RPM_PATH/$RPM_NAME.rpm | cut -d ":" -f 1|grep win8|wc -l`
			if [ $WIN8_CHECK -ge 1 ];then
				mkdir -p $RPM_XEN_PATH/$TIME_STAMP-$XEN_FOR_WIN8_BRANCH
				cp -rf $RPM_PATH/xen_win8*.rpm $RPM_XEN_PATH/$TIME_STAMP-$XEN_FOR_WIN8_BRANCH/
				cp -rf /root/build-server/log/xen_for_win8_patch.txt $RPM_XEN_PATH/$TIME_STAMP-$XEN_FOR_WIN8_BRANCH/
                                cp -rf /root/build-server/log/qemu_for_win8_patch.txt $RPM_XEN_PATH/$TIME_STAMP-$XEN_FOR_WIN8_BRANCH/
				rm -rf $RPM_PATH/xen_win8*.rpm
			else
                        	mkdir -p $RPM_XEN_PATH/$TIME_STAMP-$XEN_BRANCH
                        	cp -rf $RPM_PATH/xen-*.rpm $RPM_XEN_PATH/$TIME_STAMP-$XEN_BRANCH/
				cp -rf /root/build-server/log/xen_patch.txt $RPM_XEN_PATH/$TIME_STAMP-$XEN_BRANCH/
                                cp -rf /root/build-server/log/qemu_patch.txt $RPM_XEN_PATH/$TIME_STAMP-$XEN_FOR_WIN8_BRANCH/
                        	rm -rf $RPM_PATH/xen-*.rpm
                	fi
		else
			echo "This is not kernel or xen rpm !"
		fi
		((RPM=$RPM-1))
		echo $RPM_NUM
	done
	echo "rpm list done" 
	echo "no more new rpm file to list! Thanks"

}


rpm_list
exit 0
