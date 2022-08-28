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
	./scripts/run-docker.sh env TERMUX_NDK_VERSION_NUM=23 TERMUX_NDK_REVISION=c ./scripts/setup-android-sdk.sh
	;;
*)
	echo "[!] ERROR: Unsupported option $1"
	exit 1
esac

rm -fr "$REPOROOT/output"

./scripts/run-docker.sh ./build-package.sh -a "$TERMUX_ARCH" "$2"

echo "[*] Moving packages..."
mv "output" "$REPOROOT/output"

echo "[*] Generated packages:"
ls -lh "$REPOROOT/output"
