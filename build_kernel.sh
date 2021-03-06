#!/bin/bash
#
# Swift Kernel Build Script 
# Coded by BlackMesa/TaifAljaloo/AnanJaser1211 @2018
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

clear
# Init Fields
SW_VERSION=V1
SW_DATE=$(date +%Y%m%d)
SW_TOOLCHAIN=/home/taif/kernel/toolchain/aarch64-linux-android-4.9-kernel/bin/aarch64-linux-android-
SW_JOBS=4
SW_DIR=$(pwd)
export ARCH=arm64
export ANDROID_MAJOR_VERSION=o
export CROSS_COMPILE=$SW_TOOLCHAIN
# Init Methods
CLEAN_SOURCE()
{
    make clean
	make mrproper
	rm -r -f $SW_DIR/swift/dtb.img
}
BUILD_ZIMAGE()
{
	echo "----------------------------------------------"
	echo "Building zImage for $SW_VARIANT..."
	echo " "
	export LOCALVERSION=-Swift_Kernel-$SW_VERSION-$SW_VARIANT-$SW_DATE
	make -j$SW_JOBS $SW_DEFCON
	make -j$SW_JOBS
	echo " "
}
PACK_JACPOTLTE_IMG()
{
	echo "----------------------------------------------"
	echo "Packing boot.img for $SW_VARIANT..."
	echo " "
	cp -rf $SW_DIR/sw-tools/Unified/ramdisk $SW_DIR/sw-tools/AIK-Linux
	cp -rf $SW_DIR/sw-tools/Unified/split_img $SW_DIR/sw-tools/AIK-Linux
	mv $SW_DIR/arch/arm64/boot/Image $SW_DIR/sw-tools/AIK-Linux/split_img/boot.img-zImage
	mv $(pwd)/arch/arm64/boot/dtb.img $SW_DIR/sw-tools/AIK-Linux/split_img/boot.img-dtb
	$SW_DIR/sw-tools/AIK-Linux/repackimg.sh --nosudo
	mv $SW_DIR/sw-tools/AIK-Linux/image-new.img $SW_DIR/sw-tools/out/boot-$SW_VARIANT.img
	$SW_DIR/sw-tools/AIK-Linux/cleanup.sh --nosudo
}
PACK_JACKPOT2LTE_IMG()
{
	echo "----------------------------------------------"
	echo "Packing boot.img for $SW_VARIANT..."
	echo " "
	cp -rf $SW_DIR/sw-tools/Unified/ramdisk $SW_DIR/sw-tools/AIK-Linux
	cp -rf $SW_DIR/sw-tools/Unified/split_img $SW_DIR/sw-tools/AIK-Linux
	mv $SW_DIR/arch/arm64/boot/Image $SW_DIR/sw-tools/AIK-Linux/split_img/boot.img-zImage
	mv $(pwd)/arch/arm64/boot/dtb.img $SW_DIR/sw-tools/AIK-Linux/split_img/boot.img-dtb
	$SW_DIR/sw-tools/AIK-Linux/repackimg.sh --nosudo
	mv $SW_DIR/sw-tools/AIK-Linux/image-new.img $SW_DIR/sw-tools/out/boot-$SW_VARIANT.img
	$SW_DIR/sw-tools/AIK-Linux/cleanup.sh --nosudo
}
# Main Menu
clear
echo "----------------------------------------------"
echo "SwiftKernel $SW_VERSION Build Script"
echo "Coded by BlackMesa/TaifAljaloo/ananjaser1211"
echo "----------------------------------------------"
PS3='Please select your option (1-4): '
menuvar=("JACKPOTLTE" "JACKPOT2LTE" "Pack a Zip" "Exit")
select menuvar in "${menuvar[@]}"
do
    case $menuvar in
        "JACKPOTLTE")
            clear
            echo "----------------------------------------------"
            echo "Cleaning up source..."
            echo " "
            CLEAN_SOURCE
            echo " "
            echo "----------------------------------------------"
            echo "Starting JACKPOTLTE kernel build..."
            SW_VARIANT=A530F
            SW_DEFCON=exynos7885-jackpotlte_defconfig
            BUILD_ZIMAGE
            PACK_JACPOTLTE_IMG
            echo " "
            echo "----------------------------------------------"
            echo "JACKPOTLE kernel build finished."
            echo "boot.img is located into SW-TOOLS/OUT."
            echo "Press any key for end the script."
            echo "----------------------------------------------"
            read -n1 -r key
            break
            ;;
        "JACKPOT2LTE")
            clear
            echo "----------------------------------------------"
            echo "Cleaning up source..."
            echo " "
            CLEAN_SOURCE
            echo " "
            echo "----------------------------------------------"
            echo "Starting JACKPOT2LTE kernel build..."
            SW_VARIANT=A730F
            SW_DEFCON=exynos7885-jackpot2lte_defconfig
            BUILD_ZIMAGE
            PACK_JACKPOT2LTE_IMG
            echo " "
            echo "----------------------------------------------"
            echo "JACKPOT2LTE kernel build finished."
            echo "boot.img is located into SW-TOOLS/OUT."
            echo "Press any key for end the script."
            echo "----------------------------------------------"
            read -n1 -r key
            break
            ;;
			"Pack a Zip")
			echo "----------------------------------------------"
            echo "Copying boot images to kernel zip..."
            echo " "
            cp -rf $SW_DIR/sw-tools/out/boot-A530F.img $SW_DIR/sw-tools/swiftkernel/swift/a530f
			cp -rf $SW_DIR/sw-tools/out/boot-A730F.img $SW_DIR/sw-tools/swiftkernel/swift/a730f
			echo "----------------------------------------------"
            echo "packing a flashable zip...."
            echo " "
            cd $SW_DIR/sw-tools/swiftkernel/
            zip -r -9 - * > SWIFT-KERNEL-$SW_VERSION.zip 
            echo "----------------------------------------------"
            echo "Copying the flashabel zip into the phone..."
            mv $SW_DIR/sw-tools/swiftkernel/SWIFT-KERNEL-$SW_VERSION.zip $SW_DIR/sw-tools/ADB
            cd $SW_DIR/sw-tools/ADB
            adb devices
            adb push SWIFT-KERNEL-$SW_VERSION.zip  /sdcard/
             echo "----------------------------------------------"
            echo "Rebooting the phone into twrp..."
            cd $SW_DIR/sw-tools/ADB
            adb reboot recovery
            echo "----------------------------------------------"
            echo "Packing the zip and copying it to the phone is done 
                  flash it and enjoy your time..."
			read -n1 -r key
            break
            ;;
        "Exit")
            break
            ;;
        *) echo Invalid option.;;
    esac
done
