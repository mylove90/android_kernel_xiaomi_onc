#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2018 Raphiel Rollerscaperers (raphielscape)
# Copyright (C) 2018 Rama Bondan Prakoso (rama982)
# Android Kernel Build Script

# Install build package for debian based linux
sudo apt install bc bash git-core gnupg build-essential \
    zip curl make automake autogen autoconf autotools-dev libtool shtool python \
    m4 gcc libtool zlib1g-dev flex bison libssl-dev

# Clone toolchain
rm -rf stock
git clone https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 -b android-9.0.0_r49 --depth=1 stock
rm -rf stock_32
git clone https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9 -b android-9.0.0_r49 --depth=1 stock_32

# Clone AnyKernel3
git clone https://github.com/rama982/AnyKernel3 -b onc-miui

#Download Clang
if [ ! -d clang ]; then
    wget https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/android-9.0.0_r6/clang-4691093.tar.gz
    mkdir -p clang/clang-4691093/
    tar xvzf clang-4691093.tar.gz -C clang/clang-4691093
    rm clang-4691093.tar.gz
fi

# Make a backup for the toolchain to refresh after cleaning by clean.sh script
#  (avoiding build bug)
tar cjvf ../toolchain.tbz stock stock_32 clang
