#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2018 Raphiel Rollerscaperers (raphielscape)
# Copyright (C) 2018 Rama Bondan Prakoso (rama982)
# Android Kernel Build Script

make clean
make mrproper
cd AnyKernel3
make clean

# Check if a saved toolchain tar exist and refresh from it if so
cd ..
if [ -f ../toolchain.tbz ]; then
	rm -rf stock stock_32 clang
	tar xjvf ../toolchain.tbz
else
	echo Please launch \"gettools.sh\" script to get a toolchain and create a backup archive to restore from!
	echo -n "Want to run it right now? (Y/n): "
	read a
	[ "$a" != "n" ] && sh gettools.sh
fi
