#!/bin/bash
mount proc /proc -t proc
mount sysfs /sys -t sysfs
mount devtmpfs /dev -t devtmpfs
mount securityfs /sys/kernel/security -t securityfs
mount tmpfs /dev/shm -t tmpfs
mount devpts /dev/pts -t devpts
mount tmpfs /run -t tmpfs
mount tmpfs /sys/fs/cgroup -t tmpfs

