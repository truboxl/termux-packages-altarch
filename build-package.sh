#!/bin/sh
set -e

export REPOROOT="$PWD"
export TERMUX_ARCH

cd "$REPOROOT/termux-packages"
git reset --hard

case "$1" in
arm-vfpv3-d16)
	TERMUX_ARCH=arm
	patch -p1 -i "$REPOROOT/termux-packages.$1.lf.patch"
	patch -p1 -i "$REPOROOT/termux-packages.$1.crlf.patch"
	./scripts/setup-ubuntu.sh
	TERMUX_NDK_VERSION_NUM=23 TERMUX_NDK_REVISION=c ./scripts/setup-android-sdk.sh
	rm -fr "$REPOROOT/output"
	TERMUX_NDK_VERSION_NUM=23 TERMUX_NDK_REVISION=c ./build-package.sh -a "$TERMUX_ARCH" "$2"
	;;
*)
	echo "[!] ERROR: Unsupported option $1"
	exit 1
esac

echo "[*] Moving packages..."
mv "output" "$REPOROOT/output"

echo "[*] Generated packages:"
ls -lh "$REPOROOT/output"
