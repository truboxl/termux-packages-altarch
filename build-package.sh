#!/usr/bin/env bash
set -e

export REPOROOT="$PWD"
export TERMUX_NDK_VERSION_LATEST=$(. "$REPOROOT/termux-packages/scripts/properties.sh"; echo "$TERMUX_NDK_VERSION")
export TERMUX_ARCH
export TERMUX_NDK_VERSION_NUM
export TERMUX_NDK_REVISION
export TERMUX_PKG_ENABLE_CLANG16_PORTING=false

pushd "$REPOROOT/termux-packages"
git reset --hard

case "$1" in
arm-vfpv3-d16)
	TERMUX_ARCH=arm
	TERMUX_NDK_VERSION_NUM=23
	TERMUX_NDK_REVISION=c
	# Special packages that extract libs from Android NDK that
	# are built without NEON but the version label is kept
	# higher to avoid build issues from other packages
	for p in libandroid-stub libc++ ndk-multilib ndk-sysroot vulkan-loader-android; do
		sed \
			-e "s|^TERMUX_PKG_SRCURL=.*|TERMUX_PKG_SRCURL=https://dl.google.com/android/repository/android-ndk-r23c-linux.zip|" \
			-e "s|^TERMUX_PKG_SHA256=.*|TERMUX_PKG_SHA256=6ce94604b77d28113ecd588d425363624a5228d9662450c48d2e4053f8039242|" \
			-i "packages/$p/build.sh"
	done
	patch -p1 -i "$REPOROOT/termux-packages.$1.lf.patch"
	#patch -p1 -i "$REPOROOT/termux-packages.$1.crlf.patch"

	echo "[*] Setting up toolchain ..."
	t0=$(cut -d'.' -f1 /proc/uptime)
	./scripts/setup-ubuntu.sh &>/dev/null
	./scripts/setup-android-sdk.sh &>/dev/null
	t1=$(cut -d'.' -f1 /proc/uptime)
	echo "[*] Done ... $((t1-t0))s"

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

echo "[*] Moving packages ..."
mv "output" "$REPOROOT/output"

echo "[*] Generated packages:"
ls -lh "$REPOROOT/output"

popd
