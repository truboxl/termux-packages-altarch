#!/usr/bin/env bash
set -e

export REPOROOT="$PWD"
export TERMUX_NDK_VERSION_LATEST=$(. "$REPOROOT/termux-packages/scripts/properties.sh"; echo "$TERMUX_NDK_VERSION")
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

# some packages uses TERMUX_NDK_VERSION as TERMUX_PKG_VERSION
# rename to avoid downloading "newer" version during generate-bootstraps.sh phase
for package in libc++ ndk-multilib ndk-sysroot vulkan-loader-android; do
	_REVISION=$(. "$REPOROOT/termux-packages/packages/$package/build.sh" | echo "$TERMUX_PKG_REVISION")
	[ -n "$_REVISION" ] && _REVISION="-${_REVISION}"
	if [ -e "$REPOROOT/output/${package}_${TERMUX_NDK_VERSION_NUM}${TERMUX_NDK_REVISION}${_REVISION}_${TERMUX_ARCH}.deb" ]; then
		mv -v "$REPOROOT/output/${package}_${TERMUX_NDK_VERSION_NUM}${TERMUX_NDK_REVISION}${_REVISION}_${TERMUX_ARCH}.deb" "$REPOROOT/output/${package}_${TERMUX_NDK_VERSION_LATEST}${REVISION}_${TERMUX_ARCH}.deb"
	fi
done

echo "[*] Moving packages..."
mv "output" "$REPOROOT/output"

echo "[*] Generated packages:"
ls -lh "$REPOROOT/output"
