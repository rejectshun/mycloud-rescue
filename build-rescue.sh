#!/bin/bash
#
# This script is used to create a rescue image for the WD mycloud

# compiling options
export ARCH=armhf
export CROSS_COMPILE=arm-linux-gnueabihf-

current=`pwd`

# source urls
wd_url="http://download.wdc.com/gpl"
wd_ver="gpl-source-wd_my_cloud-04.01.04-422.zip"

buildroot_url="http://buildroot.uclibc.org/downloads/"
buildroot_ver="buildroot-2015.08.1"

# set pathes
dir_build="${current}/build"
dir_dl="${current}/download"
dir_custom="${current}/custom"
dir_conf="${current}/conf"
dir_tftp="${current}/tftpboot"

kernel="${dir_build}/wd/packages/kernel_3.2"

[[ ! -e ${dir_dl} ]] & mkdir -p ${dl_dir}
[[ ! -e ${dir_build} ]] & mkdir -p ${build_dir}

# Download WD GPL if needed
if [ ! -e $kernel ]
then
    if [ ! -e ${dir_dl}/$wd_ver ]
    then
  	if wget ${wd_url}/${wd_ver} -O ${dir_dl}/$wd_ver ; then
  		echo "${wd_ver} downloaded"
	else
	
	echo "please download the GPL file from:"
  	echo "${wd_url}/$wd_ver"
  	echo "to ${dir_dl}/$wd_ver"
	fi
    fi
  [[ ! -e ${dir_build}/wd ]] && mkdir -p ${build_dir}/wd
  unzip ${dir_dl}/$wd_ver -d ${dir_build}/wd
fi

# Download buildroot
if [ ! -e ${dir_dl}/$buildroot_ver  ]
then
  wget ${buildroot_url}/${buildroot_ver}.tar.bz2 -O ${dir_dl}/${buildroot_ver}.tar.bz2
fi
if [ ! -e "${dir_build}/${buildroot_ver}" ]
then
  cd ${dir_build}
  tar jxf ${dir_dl}/${buildroot_ver}.tar.bz2
fi


# Create rootfs with buildroot
cd ${dir_build}/${buildroot_ver}

if [ ! -e .config ]
then
  cp $current/buildroot-config .config
  make oldconfig
fi

make -j8

if [ "$?" != "0" ]
then
  echo "generation of buildroot failed?!"
  exit 1
fi


# Compile kernel
if [ ! -e $kernel/_bin/lib ]
then
  # compile kernel at least once
  cd $kernel
  make
fi

# Copy kernel modules into buildroot
cd $current
[[ ! -e ${dir_build}/${buildroot_ver}/overlay ]] && mkdir -p ${build_dir}/${buildroot_ver}/overlay

build_rootfs () {

cd ${dir_build}/${buildroot_ver}/overlay

cp -R $dir_custom/ .
cp -R $kernel/_bin/lib .

find . | cpio -H newc -o | gzip -9 > $current/rootfs.cpio.gz

}

fakeroot build_rootfs

# Build uImage with new rootfs
cp kernel-config $kernel/_bld/.config
cd $kernel
make uImage

cd $current
cp $kernel/_bld/arch/arm/boot/uImage ${dir_tftp}/mycloud_rescue

echo "Done: uImage generated"

exit 0

