#!/usr/bin/env bash
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
	# Special packages that extract libs from Android NDK that
	# are built without NEON but the version label is kept
	# higher to avoid build issues from other packages
	local p
	for p in libandroid-stub libc++ ndk-multilib ndk-sysroot vulkan-loader-android; do
		sed \
			-e "s|^TERMUX_PKG_SRCURL=.*|TERMUX_PKG_SRCURL=https://dl.google.com/android/repository/android-ndk-r23c-linux.zip|" \
			-e "s|^TERMUX_PKG_SHA256=.*|TERMUX_PKG_SHA256=6ce94604b77d28113ecd588d425363624a5228d9662450c48d2e4053f8039242|" \
			-i "$REPOROOT/packages/$p/build.sh"
	done
	patch -p1 -i "$REPOROOT/termux-packages.$1.lf.patch"
	#patch -p1 -i "$REPOROOT/termux-packages.$1.crlf.patch"

	# Temporarily add this until pull request is merged
	cp -fv "$REPOROOT/generate-bootstraps-patch.sh" scripts/generate-bootstraps.sh
	# Should not need to mkdir "$REPOROOT/output" if build-package.sh worked
	./scripts/generate-bootstraps.sh -c "$REPOROOT/output" --architectures "$TERMUX_ARCH"
	;;
*)
	echo "[!] ERROR: Unsupported option $1"
	exit 1
esac

echo "[*] Moving bootstrap archive to $REPOROOT..."

case "$1" in
arm-vfpv3-d16)
	mv -v bootstrap-arm.zip "$REPOROOT/bootstrap-$1.zip"
	;;
*)
	mv -v bootstrap-*.zip "$REPOROOT"
esac
