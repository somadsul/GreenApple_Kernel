#!/bin/bash
# kernel build script by SomAdsul V3.0 (optimized from apq8084 kernel source)

export MODEL=S7
export ARCH=arm
export BUILD_CROSS_COMPILE=/home/somadsul/toolchains/UBERTC4.9/bin/arm-eabi-
export BUILD_JOB_NUMBER=`grep processor /proc/cpuinfo|wc -l`
RDIR=$(pwd)
OUTDIR=$RDIR/arch/$ARCH/boot
DTSDIR=$RDIR/arch/$ARCH/boot/dts
INCDIR=$RDIR/include

if [ $MODEL = S7 ]
then
	KERNEL_DEFCONFIG=GreenApple_defconfig
else if [ $MODEL = N7 ]
then
	KERNEL_DEFCONFIG=GreenApple_defconfig
else if [ $MODEL = GraceUX ]
then
	KERNEL_DEFCONFIG=GreenApple_defconfig
else [ $MODEL =Stock ]
	KERNEL_DEFCONFIG=GreenApple_defconfig
fi
fi
fi

FUNC_CLEAN_DTB()
{
	if ! [ -d $RDIR/arch/$ARCH/boot/dts ] ; then
		echo "no directory : "$RDIR/arch/$ARCH/boot/dts""
	else
		echo "rm files in : "$RDIR/arch/$ARCH/boot/dts/*.dtb""
		rm $RDIR/arch/$ARCH/boot/dts/*.dtb
		rm $RDIR/arch/$ARCH/boot/dtb/*.dtb
		rm $RDIR/arch/$ARCH/boot/Image
		rm $RDIR/arch/$ARCH/boot/boot.img-dtb
		rm $RDIR/arch/$ARCH/boot/boot.img-zImage
	fi
}

FUNC_BUILD_KERNEL()
{
	echo ""
        echo "=============================================="
        echo "START : FUNC_BUILD_KERNEL"
        echo "=============================================="
        echo ""
        echo "build common config="$KERNEL_DEFCONFIG ""
        echo "build variant config="$MODEL ""

	FUNC_CLEAN_DTB

	make -j$BUILD_JOB_NUMBER ARCH=$ARCH \
			CROSS_COMPILE=$BUILD_CROSS_COMPILE \
			$KERNEL_DEFCONFIG || exit -1

	make -j$BUILD_JOB_NUMBER ARCH=$ARCH \
			CROSS_COMPILE=$BUILD_CROSS_COMPILE || exit -1
	
	echo ""
	echo "================================="
	echo "END   : FUNC_BUILD_KERNEL"
	echo "================================="
	echo ""
}

FUNC_BUILD_RAMDISK()
{
	mv $RDIR/arch/$ARCH/boot/zImage $RDIR/arch/$ARCH/boot/boot.img-zImage

	case $MODEL in
	S7)
		rm -f $RDIR/ramdisk/S7/split_img/boot.img-zImage
		mv -f $RDIR/arch/$ARCH/boot/boot.img-zImage $RDIR/ramdisk/S7/split_img/boot.img-zImage
		cd $RDIR/ramdisk/S7
		./repackimg.sh
		echo SEANDROIDENFORCE >> image-new.img
		;;
	N7)
		rm -f $RDIR/ramdisk/N7/split_img/boot.img-zImage
		mv -f $RDIR/arch/$ARCH/boot/boot.img-zImage $RDIR/ramdisk/N7/split_img/boot.img-zImage
		cd $RDIR/ramdisk/N7
		./repackimg.sh
		echo SEANDROIDENFORCE >> image-new.img
		;;
	GraceUX)
		rm -f $RDIR/ramdisk/GraceUX/split_img/boot.img-zImage
		mv -f $RDIR/arch/$ARCH/boot/boot.img-zImage $RDIR/ramdisk/GraceUX/split_img/boot.img-zImage
		cd $RDIR/ramdisk/GraceUX
		./repackimg.sh
		echo SEANDROIDENFORCE >> image-new.img
		;;
	Stock)
		rm -f $RDIR/ramdisk/SM-T700/split_img/boot.img-zImage
		mv -f $RDIR/arch/$ARCH/boot/boot.img-zImage $RDIR/ramdisk/GraceUX/split_img/boot.img-zImage
		cd $RDIR/ramdisk/GraceUX
		./repackimg.sh
		echo SEANDROIDENFORCE >> image-new.img
		;;
	*)
		echo "Unknown device: $MODEL"
		exit 1
		;;
	esac
}

# MAIN FUNCTION
rm -rf ./build.log
(
    START_TIME=`date +%s`

	FUNC_BUILD_KERNEL
	FUNC_BUILD_RAMDISK

    END_TIME=`date +%s`
	
    let "ELAPSED_TIME=$END_TIME-$START_TIME"
    echo "Total compile time is $ELAPSED_TIME seconds"
) 2>&1	 | tee -a ./build.log
