#!/bin/bash
apt-get install autoconf xutils-dev xserver-xorg-dev libtool x11proto-gl-dev libx11-xcb-dev libxcb-glx0 libxcb-glx0-dev  libxcb-dri2-0-dev libxcb-xfixes0-dev mesa-utils  flex  bison bridge-utils -y

export PREFIX=/opt/xorg
export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig:$PREFIX/share/pkgconfig
export LD_LIBRARY_PATH=$PREFIX/lib
export PATH=$PREFIX/bin:$PATH
cd /root/libdrm-hsw
./autogen.sh --prefix=/opt/xorg
make
make install
cd /root/mesa-hsw
./autogen.sh --prefix=/opt/xorg --disable-gallium-egl --disable-gallium-gbm --without-gallium-drivers --with-dri-drivers=i965
make
make install
cd /root/xf86-video-intel-hsw
./autogen.sh --prefix=/opt/xorg
make
make install
ln -s /opt/xorg/lib/xorg/modules/drivers/* /usr/lib/xorg/modules/drivers/ -f
