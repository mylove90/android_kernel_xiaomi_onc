#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2018 Raphiel Rollerscaperers (raphielscape)
# Copyright (C) 2018 Rama Bondan Prakoso (rama982)
# Android Kernel Build Script

# Main environtment
KERNEL_DIR=${HOME}/$(basename $(pwd))
KERN_IMG=$KERNEL_DIR/out/arch/arm64/boot/Image.gz-dtb
ZIP_DIR=$KERNEL_DIR/AnyKernel3
CONFIG=onclite-perf_defconfig
CROSS_COMPILE="aarch64-linux-android-"
CROSS_COMPILE_ARM32="arm-linux-androideabi-"
PATH=:"${KERNEL_DIR}/clang/clang-r353983c/bin:${PATH}:${KERNEL_DIR}/stock/bin:${PATH}:${KERNEL_DIR}/stock_32/bin:${PATH}"

# Export
export ARCH=arm64
export CROSS_COMPILE
export CROSS_COMPILE_ARM32

# Install build package for debian based linux
sudo apt install bc bash git-core gnupg build-essential \
    zip curl make automake autogen autoconf autotools-dev libtool shtool python \
    m4 gcc libtool zlib1g-dev flex

# Clone toolchain
git clone https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 -b android-10.0.0_r29 --depth=1 stock
git clone https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9 -b android-10.0.0_r29 --depth=1 stock_32

# Clone AnyKernel3
git clone https://github.com/mylove90/AnyKernel3

# Download libufdt
if [ ! -d libufdt ]; then
    wget https://android.googlesource.com/platform/system/libufdt/+archive/refs/tags/android-10.0.0_r29/utils.tar.gz
    mkdir -p libufdt
    tar xvzf utils.tar.gz -C libufdt
    rm utils.tar.gz
fi

#Download Clang
if [ ! -d clang ]; then
    wget https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/tags/android-10.0.0_r29/clang-r353983c.tar.gz
    mkdir -p clang/clang-r353983c/
    tar xvzf clang-r353983c.tar.gz -C clang/clang-r353983c
    rm clang-r353983c.tar.gz
fi

# Build start
make O=out $CONFIG
make -j$(nproc --all) O=out \
                      ARCH=arm64 \
                      CC=clang \
CLANG_TRIPLE=aarch64-linux-gnu- \
CROSS_COMPILE=aarch64-linux-android-
if ! [ -a $KERN_IMG ]; then
    echo "Build error!"
    exit 1
fi

cd $ZIP_DIR
make clean &>/dev/null
cd ..

# For MIUI Build
# Credit Adek Maulana <adek@techdro.id>
OUTDIR="$KERNEL_DIR/out/"
VENDOR_MODULEDIR="$KERNEL_DIR/AnyKernel3/modules/vendor/lib/modules"
STRIP="$KERNEL_DIR/stock/bin/$(echo "$(find "$KERNEL_DIR/stock/bin" -type f -name "aarch64-*-gcc")" | awk -F '/' '{print $NF}' |\
            sed -e 's/gcc/strip/')"
for MODULES in $(find "${OUTDIR}" -name '*.ko'); do
    "${STRIP}" --strip-unneeded --strip-debug "${MODULES}"
    "${OUTDIR}"/scripts/sign-file sha512 \
            "${OUTDIR}/certs/signing_key.pem" \
            "${OUTDIR}/certs/signing_key.x509" \
            "${MODULES}"
    find "${OUTDIR}" -name '*.ko' -exec cp {} "${VENDOR_MODULEDIR}" \;
    case ${MODULES} in
            */wlan.ko)
        cp "${MODULES}" "${VENDOR_MODULEDIR}/pronto_wlan.ko" ;;
    esac
done
echo -e "\n(i) Done moving modules"
rm "${VENDOR_MODULEDIR}/wlan.ko"
cd libufdt/src && python mkdtboimg.py create $OUTDIR/arch/arm64/boot/dtbo.img $OUTDIR/arch/arm64/boot/dts/qcom/*.dtbo
cd $ZIP_DIR
cp $KERN_IMG zImage
cp $OUTDIR/arch/arm64/boot/dtbo.img $ZIP_DIR
make normal &>/dev/null
echo "Flashable zip generated under $ZIP_DIR."
cd ..
# Build end
