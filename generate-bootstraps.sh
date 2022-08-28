#!/bin/sh
set -e

export REPOROOT="$PWD"
export TERMUX_ARCH

cd "$REPOROOT"/termux-packages
git reset --hard

case "$1" in
arm-vfpv3-d16)
	TERMUX_ARCH=arm
	patch -p1 -i "$REPOROOT/termux-packages.$1.lf.patch"
	patch -p1 -i "$REPOROOT/termux-packages.$1.crlf.patch"
	;;
*)
	echo "[!] ERROR: Unsupported option $1"
	exit 1
esac

# Temporarily add this until pull request is merged
patch -p1 -i "$REPOROOT/generate-bootstraps.sh.patch"

# Should not need to mkdir "$REPOROOT/output" if build-package.sh worked

./scripts/generate-bootstraps.sh -c "$REPOROOT/output" --architectures "$TERMUX_ARCH"

echo "[*] Moving bootstrap archive to $REPOROOT..."

case "$1" in
arm-vfpv3-d16)
	mv -v bootstrap-arm.zip "$REPOROOT/bootstrap-$1.zip"
	;;
*)
	mv -v bootstrap-*.zip "$REPOROOT"
esac
