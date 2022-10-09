#!/bin/sh
set -e

export REPOROOT="$PWD"
export TERMUX_ARCH
export TERMUX_NDK_VERSION_NUM
export TERMUX_NDK_REVISION

cd "$REPOROOT/termux-packages"
git reset --hard

case "$1" in
arm-vfpv3-d16)
	TERMUX_ARCH=arm
	TERMUX_NDK_VERSION_NUM=23
	TERMUX_NDK_REVISION=c
	patch -p1 -i "$REPOROOT/termux-packages.$1.lf.patch"
	patch -p1 -i "$REPOROOT/termux-packages.$1.crlf.patch"
	./scripts/setup-ubuntu.sh
	./scripts/setup-android-sdk.sh
	rm -fr "$REPOROOT/output"
	./build-package.sh -a "$TERMUX_ARCH" "$2"
	;;
*)
	echo "[!] ERROR: Unsupported option $1"
	exit 1
esac

echo "[*] Moving packages..."
mv "output" "$REPOROOT/output"

echo "[*] Generated packages:"
ls -lh "$REPOROOT/output"
