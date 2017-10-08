#!/bin/bash 

# Build Script for compiling Liberty Kernel

# Developed by Griffin98

################### PREREQUISITES #####################
#                                                     #
# What you need installed to compile                  # 
# gcc, gpp, cpp, c++, g++, lzma, lzop, ia32-libs flex,#
# ccache                                              #
# If on 64bit Linux, install gcc multilib             #
#                                                     #
#######################################################




#######################################################
# Variables
#######################################################
CCACHE_DIRR=~/.ccache/liberty-kernel
OUTPUT_DIRR=$(pwd)/OUTPUT
BUILD_JOB_NUMBER=`grep processor /proc/cpuinfo|wc -l`
BOOTIMG_LOC=$(pwd)/liberty_tools/zip_files/boot.img
BOOTIMG_LOC_BUILT=$(pwd)/liberty_tools/bootimg_tools/boot.img
ZIMAGE_LOC=$(pwd)/arch/arm/boot/zImage
DTIMAGE_LOC=$(pwd)/arch/arm/boot/dt.img
ZIMAGE_LOC_BUILT=$(pwd)/liberty_tools/bootimg_tools/boot_img_files/kernel
DTIMAGE_LOC_BUILT=$(pwd)/liberty_tools/bootimg_tools/boot_img_files/dt.img
ZIPFILE_LOC=$(pwd)/liberty_tools/zip_files


######################################################
# Colors
######################################################
bldred=${txtbld}$(tput setaf 1) # red
bldgrn=${txtbld}$(tput setaf 2) # green
bldorg=${txtbld}$(tput setaf 3) # orange
bldblu=${txtbld}$(tput setaf 4) # blue
bldmag=${txtbld}$(tput setaf 5) # magenta
bldcya=${txtbld}$(tput setaf 6) # cyan
bldpink=${txtbld}$(tput setaf 200) # pink
txtrst=$(tput sgr0) # Reset




initialize()
{ 
    echo ""
    echo "${bldorg}------> Initializing Kernel Build Script....... ${txtrst}" 
    if which ccache >/dev/null; then
       if [ ! -d "$CCACHE_DIRR" ]; then
             mkdir $CCACHE_DIRR
       fi      
       export CCACHE_DIR="$CCACHE_DIRR"
       export CC="ccache gcc"
       export CXX="ccache g++"
       export PATH="/usr/lib/ccache:$PATH"
       ccache --max-size=20GB #Setting maximum size of ccache to 20GB
    else
         echo ""
         echo "${bldred}Please install CCACHE first !! :( !!${txtrst}"
         exit 1
    fi   
    
    sleep 3;
    
    echo ""
    read -p "${bldpink}Enter your device architectutre :${txtrst}" arch
    export ARCH=$arch
    
    echo""
    read -p "${bldpink}Enter your toolchain path :${txtrst}" cross_compile
    export CROSS_COMPILE="$cross_compile"
}


cleanup()
{
    echo ""
    echo ""
    echo "${bldorg}------> Please Wait While we perform little Housekeeping.......${txtrst}"
    echo ""
    make clean && make mrproper
    rm -rf $OUTPUT_DIRR
    rm -f $BOOTIMG_LOC
    rm -f $ZIMAGE_LOC_BUILT
    #rm -f $DTIMAGE_LOC_BUILT
}


building_zimage()
{
    echo ""
    echo ""
    echo "${bldorg}------> Building zImage.......${txtrst}"
    echo ""
    read -p "${bldpink}Enter your defconfig file name :${txtrst}" def_file
    echo ""
    make $def_file
    echo ""
    echo "${bldpink}Build Now Starting with ${BUILD_JOB_NUMBER} CPU Thread${txtrst}"
    echo ""
    time make -j$BUILD_JOB_NUMBER
    if [ ! -e $ZIMAGE_LOC ]; then
        echo ""
        echo "${bldred}Failed to generate zImage see build log${txtrst}"
        exit 1
    else
        echo ""
        echo "${bldgrn}Building zImage Completed Successfully${txtrst}"
    fi    
}


generate_bootimage()
{
  echo ""
  echo ""
  echo "${bldorg}------> Building boot.img.......${txtrst}"
  mv $ZIMAGE_LOC $ZIMAGE_LOC_BUILT
  cd liberty_tools/bootimg_tools
  ./mkboot boot_img_files boot.img
  cd ../..
}

flashable_zip()
{
  echo ""
  echo ""
  echo "${bldorg}------> Creating Flashable Zip.......${txtrst}"
  mv $BOOTIMG_LOC_BUILT $BOOTIMG_LOC
  cd  $ZIPFILE_LOC
  zip -r Kernel.zip * >/dev/null
  cd ../..
  mkdir -p $OUTPUT_DIRR
  mv $ZIPFILE_LOC/Kernel.zip $OUTPUT_DIRR
  
}


main() #Main Function of Program
{
      initialize
      cleanup
      building_zimage
      #building_dts
      generate_bootimage
	  flashable_zip
	  echo ""
	  echo ""
	  echo ""
	  echo "${bldred}Building Kernel Completed Successfully !!! :) ${txtrst}"
}


######################################################
# Start of Script
######################################################
    rm -rf *.log
    clear
    echo ""
    echo ""
    echo "${bldblu}   _      _ _               _             _  __                    _ ${txtrst}" 
    echo "${bldblu}  | |    (_) |             | |           | |/ /                   | |${txtrst}"
    echo "${bldblu}  | |     _| |__   ___ _ __| |_ _   _    | ' / ___ _ __ _ __   ___| |${txtrst}"
    echo "${bldblu}  | |    | | '_ \ / _ \ '__| __| | | |   |  < / _ \ '__| '_ \ / _ \ |${txtrst}"
    echo "${bldblu}  | |____| | |_) |  __/ |  | |_| |_| |   | . \  __/ |  | | | |  __/ |${txtrst}"
    echo "${bldblu}  |______|_|_.__/ \___|_|   \__|\__, |   |_|\_\___|_|  |_| |_|\___|_|${txtrst}"
    echo "${bldblu}                                 __/ |                               ${txtrst}"
    echo "${bldblu}                                |___/                                ${txtrst}"                      

    main
   
