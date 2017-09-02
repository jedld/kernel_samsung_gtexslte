#!/bin/bash
##
#  Copyright (C) 2015, Samsung Electronics, Co., Ltd.
#  Written by System S/W Group, S/W Platform R&D Team,
#  Mobile Communication Division.
##

set -e -o pipefail

# export CROSS_COMPILE=~/android-work/prebuilts/gcc/linux-x86/arm/arm-eabi-4.8/bin/arm-eabi-
export CROSS_COMPILE=/home/jedld/linaro/toolchain/bin/arm-linux-gnueabihf-
export ARCH=arm

PLATFORM=sc8830
DEFCONFIG=gtexslte_defconfig

KERNEL_PATH=$(pwd)
MODULE_PATH=~/android-work/out/target/product/gtexslte/root/lib/modules
EXTERNAL_MODULE_PATH=${KERNEL_PATH}/external_module

JOBS=`grep processor /proc/cpuinfo | wc -l`

function build_kernel() {
	make ${DEFCONFIG}
	make headers_install
	make -j${JOBS}
	make modules
	make dtbs
	./scripts/mkdtimg.sh -i ${KERNEL_PATH}/arch/arm/boot/dts/ -o dt.img
	make -C ${EXTERNAL_MODULE_PATH}/wifi KDIR=${KERNEL_PATH}

	[ -d ${MODULE_PATH} ] && rm -rf ${MODULE_PATH}
	mkdir -p ${MODULE_PATH}

	find ${KERNEL_PATH}/drivers -name "*.ko" -exec cp -f {} ${MODULE_PATH} \;
	find -L ${EXTERNAL_MODULE_PATH} -name "*.ko" -exec cp -f {} ${MODULE_PATH} \;
}

function clean() {
	[ -d ${MODULE_PATH} ] && rm -rf ${MODULE_PATH}
	make distclean
}

function main() {
	[ "${1}" = "Clean" ] && clean || build_kernel
}

main $@
