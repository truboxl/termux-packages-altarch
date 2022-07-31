#!/bin/sh
set -e

export REPOROOT="$PWD"

cd "$REPOROOT/termux-packages"
git reset --hard

case "$1" in
arm-vfpv3-d16)
	git apply "$REPOROOT/termux-packages-$1.patch"
	;;
*)
	echo "ERROR: Unsupported option $1"
	exit 1
esac

./scripts/run-docker.sh ./scripts/build-bootstraps.sh --architectures arm

case "$1" in
arm-vfpv3-d16)
	cp ./bootstrap-arm.zip "$REPOROOT/bootstrap-$1.zip"
esac
