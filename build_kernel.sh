#!/bin/bash
##
#  Copyright (C) 2015, Samsung Electronics, Co., Ltd.
#  Written by System S/W Group, S/W Platform R&D Team,
#  Mobile Communication Division.
##

set -e -o pipefail

export CROSS_COMPILE=~/Downloads/android-ndk-r13/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64/bin/arm-linux-androideabi-
export ARCH=arm

PLATFORM=sc8830
DEFCONFIG=gtexslte_defconfig

KERNEL_PATH=$(pwd)
MODULE_PATH=${KERNEL_PATH}/modules
EXTERNAL_MODULE_PATH=${KERNEL_PATH}/external_module

# JOBS=`grep processor /proc/cpuinfo | wc -l`

function build_kernel() {
	$(MAKE) ${DEFCONFIG}
	$(MAKE) headers_install
	$(MAKE) -j${JOBS}
	$(MAKE) modules
	$(MAKE) dtbs
	$(MAKE) -C ${EXTERNAL_MODULE_PATH}/wifi KDIR=${KERNEL_PATH}
	$(MAKE) -C ${EXTERNAL_MODULE_PATH}/mali MALI_PLATFORM=${PLATFORM} BUILD=release KDIR=${KERNEL_PATH}

	[ -d ${MODULE_PATH} ] && rm -rf ${MODULE_PATH}
	mkdir -p ${MODULE_PATH}

	find ${KERNEL_PATH}/drivers -name "*.ko" -exec cp -f {} ${MODULE_PATH} \;
	find ${EXTERNAL_MODULE_PATH} -name "*.ko" -exec cp -f {} ${MODULE_PATH} \;
}

function clean() {
	[ -d ${MODULE_PATH} ] && rm -rf ${MODULE_PATH}
	$(MAKE) distclean
}

function main() {
	[ "${1}" = "Clean" ] && clean || build_kernel
}

main $@
