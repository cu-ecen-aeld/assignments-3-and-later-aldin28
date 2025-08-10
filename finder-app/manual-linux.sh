#!/bin/bash -x
# Script outline to install and build kernel.
# Author: Siddhant Jajoo.

set -e
set -u

OUTDIR=/tmp/aeld
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v5.15.163
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-

if [ $# -lt 1 ]
then
	echo "Using default directory ${OUTDIR} for output"
else
	OUTDIR=$1
	echo "Using passed directory ${OUTDIR} for output"
fi

mkdir -p ${OUTDIR}

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/linux-stable" ]; then
    #Clone only if the repository does not exist.
	echo "CLONING GIT LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
	git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi
if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
    cd linux-stable
    echo "Checking out version ${KERNEL_VERSION}"
    git checkout ${KERNEL_VERSION}
    sleep 1
    #export PATH=/usr/bin:$PATH
    make -j4 ARCH=arm64 CROSS_COMPILE=/home/aldin/coursera/arm-gnu-toolchain-13.3.rel1-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu- mrproper
    #make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- mrproper 
    sleep 1
    make -j4 ARCH=arm64 CROSS_COMPILE=/home/aldin/coursera/arm-gnu-toolchain-13.3.rel1-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu- defconfig
    #make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- defconfig
    sleep 1 
    make -j4 ARCH=arm64 CROSS_COMPILE=/home/aldin/coursera/arm-gnu-toolchain-13.3.rel1-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu- all
    make ARCH=arm64 CROSS_COMPILE=/home/aldin/coursera/arm-gnu-toolchain-13.3.rel1-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu- Image
    #make -j4 ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- all
    #make -j4 ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- Image
    
fi

echo "Adding the Image in outdir"

echo "Creating the staging directory for the root filesystem"
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]
then
	echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
    sudo rm  -rf ${OUTDIR}/rootfs
fi

# TODO: Create necessary base directories
mkdir -p ${OUTDIR}/rootfs
mkdir -p ${OUTDIR}/rootfs/bin ${OUTDIR}/rootfs/dev ${OUTDIR}/rootfs/etc ${OUTDIR}/rootfs/home ${OUTDIR}/rootfs/lib ${OUTDIR}/rootfs/lib64 ${OUTDIR}/rootfs/proc ${OUTDIR}/rootfs/sbin ${OUTDIR}/rootfs/sys ${OUTDIR}/rootfs/tmp ${OUTDIR}/rootfs/usr ${OUTDIR}/rootfs/var 
mkdir -p ${OUTDIR}/rootfs/usr/bin ${OUTDIR}/rootfs/usr/lib ${OUTDIR}/rootfs/usr/sbin
mkdir -p ${OUTDIR}/rootfs/var/log

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/busybox" ]
then
    git clone git://busybox.net/busybox.git
    cd busybox
    git checkout ${BUSYBOX_VERSION}
    # TODO:  Configure busybox
    make distclean
    make ARCH=arm64 CROSS_COMPILE=/home/aldin/coursera/arm-gnu-toolchain-13.3.rel1-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu- defconfig
else
    cd busybox
fi
#export PATH=/home/aldin/coursera/arm-gnu-toolchain-13.3.rel1-x86_64-aarch64-none-linux-gnu/bin:/home/aldin/coursera/arm-gnu-toolchain-13.3.rel1-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/bin:$PATH
#export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/snap/bin:$PATH
# TODO: Make and install busybox
#make -j4 ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}
make distclean
make ARCH=arm64 CROSS_COMPILE=/home/aldin/coursera/arm-gnu-toolchain-13.3.rel1-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu- defconfig
make -j4 ARCH=arm64 CROSS_COMPILE=/home/aldin/coursera/arm-gnu-toolchain-13.3.rel1-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu- 
make -j4 CONFIG_PREFIX=${OUTDIR}/rootfs ARCH=arm64 CROSS_COMPILE=/home/aldin/coursera/arm-gnu-toolchain-13.3.rel1-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu- install
#make CONFIG_PREFIX=${OUTDIR}/rootfs ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- install
#make CONFIG_PREFIX=${OUTDIR}/rootfs ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} install

echo "Library dependencies"
/home/aldin/coursera/arm-gnu-toolchain-13.3.rel1-x86_64-aarch64-none-linux-gnu/bin/${CROSS_COMPILE}readelf -a busybox | grep "program interpreter"
/home/aldin/coursera/arm-gnu-toolchain-13.3.rel1-x86_64-aarch64-none-linux-gnu/bin/${CROSS_COMPILE}readelf -a busybox | grep "Shared library"

# TODO: Add library dependencies to rootfs
cp /home/aldin/coursera/arm-gnu-toolchain-13.3.rel1-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib/ld-linux-aarch64.so.1  ${OUTDIR}/rootfs/lib/

cp /home/aldin/coursera/arm-gnu-toolchain-13.3.rel1-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib64/libm.so.6  ${OUTDIR}/rootfs/lib64/
cp /home/aldin/coursera/arm-gnu-toolchain-13.3.rel1-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib64/libresolv.so.2  ${OUTDIR}/rootfs/lib64/
cp /home/aldin/coursera/arm-gnu-toolchain-13.3.rel1-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib64/libc.so.6  ${OUTDIR}/rootfs/lib64/
# TODO: Make device nodes
#sudo mknod -m 666 ${OUTDIR}/rootfs/dev/null c 1 3
#sudo mknod -m 666 ${OUTDIR}/rootfs/dev/tty0 c 5 1
#sudo mknod -m 666 ${OUTDIR}/rootfs/dev/char0 c 5 1
sudo mknod -m 666 ${OUTDIR}/rootfs/dev/null c 1 3
sudo mknod -m 666 ${OUTDIR}/rootfs/dev/console c 5 1
sudo mknod -m 666 ${OUTDIR}/rootfs/dev/ttyS0 c 4 64

# TODO: Clean and build the writer utility
cd /home/aldin/coursera/assignment-1-aldin28/finder-app
make clean
make CC=/home/aldin/coursera/arm-gnu-toolchain-13.3.rel1-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-gcc
cp writer writer.c Makefile ${OUTDIR}/rootfs/home
cd -

# TODO: Copy the finder related scripts and executables to the /home directory
# on the target rootfs
cp -r /home/aldin/coursera/assignment-1-aldin28/finder-app/finder.sh /home/aldin/coursera/assignment-1-aldin28/conf /home/aldin/coursera/assignment-1-aldin28/finder-app/finder-test.sh ${OUTDIR}/rootfs/home 
cp /home/aldin/coursera/assignment-1-aldin28/finder-app/autorun-qemu.sh ${OUTDIR}/rootfs/home 
# TODO: Chown the root directory
cd ${OUTDIR}/rootfs
sudo chown -R root:root .

# TODO: Create initramfs.cpio.gz
cd "${OUTDIR}/rootfs"
find . | cpio -H newc -ov --owner root:root > ${OUTDIR}/initramfs.cpio 
gzip -f ${OUTDIR}/initramfs.cpio
cd "${OUTDIR}/linux-stable"
cp ${OUTDIR}/linux-stable/arch/arm64/boot/Image ${OUTDIR}/Image
#export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/snap/bin
