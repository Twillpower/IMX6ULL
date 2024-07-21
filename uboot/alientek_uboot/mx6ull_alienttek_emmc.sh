#!/bin/bash 
# 清理工程
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- distclean 
# 配置uboot
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- mx6ull_14x14_ddr512_emmc_defconfig
# 编译uboot
make V=1 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j12
