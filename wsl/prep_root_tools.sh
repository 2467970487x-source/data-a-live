#!/bin/bash
# Prepare WSL for building the iOS HFS+ root (tools/mkiosroot from ios-fuxi):
#  1. hfsplus.ko for the running WSL kernel (the stock WSL kernel has no HFS+): build
#     microsoft/WSL2-Linux-Kernel at the matching tag with HFSPLUS_FS=m (MODVERSIONS is on,
#     so a full build is needed for Module.symvers).
#  2. apfs-fuse (sgan81) to read the IPSW's APFS images.
#  3. Extract OS / SystemOS / AppOS from the IPSW to /opt/work/ipsw (unzip checks CRCs).
# Clones use a mirror per command only (never a global url.insteadOf).
set -euo pipefail
MIRROR=${MIRROR-https://gh-proxy.com/https://github.com/}   # ghfast.top 已 502
PROXY=${PROXY-}
if [ -n "$PROXY" ]; then
	export http_proxy=$PROXY https_proxy=$PROXY HTTP_PROXY=$PROXY HTTPS_PROXY=$PROXY
fi
IPSW=${IPSW:-/mnt/d/workbuddy/ios/ref/ipsw/iPhone10,3,iPhone10,6_16.7.16_20H392_Restore.ipsw}
W=/opt/work
log() { echo "== $(date +%T) $*"; }

log apt
DEBIAN_FRONTEND=noninteractive apt-get install -y -q libelf-dev dwarves cpio bc flex bison \
	libncurses-dev libssl-dev zstd \
	libfuse3-dev fuse3 zlib1g-dev libbz2-dev libattr1-dev cmake g++ git >/dev/null

KVER=$(uname -r)                       # 6.6.87.2-microsoft-standard-WSL2
TAG=linux-msft-wsl-${KVER%%-microsoft*}
if [ ! -f $W/wslk/fs/hfsplus/hfsplus.ko ]; then
	log "kernel $TAG  (a full kernel build: 10-30 min, watch $W/wslk-build.log)"
	[ -d $W/wslk ] || git -c url.$MIRROR.insteadOf=https://github.com/ clone -q --depth 1 -b $TAG \
		https://github.com/microsoft/WSL2-Linux-Kernel $W/wslk
	cd $W/wslk
	if [ -r /proc/config.gz ]; then
		zcat /proc/config.gz > .config
	else
		log "WARNING: /proc/config.gz missing, trying /boot/config-$KVER"
		cp "/boot/config-$KVER" .config 2>/dev/null || {
			echo "no kernel config available: the module's vermagic will not match" >&2; exit 1; }
	fi
	scripts/config --module HFSPLUS_FS --disable LOCALVERSION_AUTO
	make -s olddefconfig
	make -s -j"$(nproc)" LOCALVERSION= >$W/wslk-build.log 2>&1 || { tail -30 $W/wslk-build.log; exit 1; }
fi
log "module built: $(modinfo -F vermagic $W/wslk/fs/hfsplus/hfsplus.ko)"
grep -qw hfsplus /proc/filesystems || insmod $W/wslk/fs/hfsplus/hfsplus.ko
grep -w hfsplus /proc/filesystems

if ! command -v apfs-fuse >/dev/null; then
	log apfs-fuse
	[ -d $W/apfs-fuse ] || git -c url.$MIRROR.insteadOf=https://github.com/ clone -q --recursive \
		https://github.com/sgan81/apfs-fuse $W/apfs-fuse
	cd $W/apfs-fuse && mkdir -p build && cd build
	cmake -DUSE_FUSE3=ON .. >/dev/null && make -s -j"$(nproc)" && install -m 755 apfs-fuse apfsutil /usr/local/bin/
fi
command -v apfs-fuse

log "ipsw images"
mkdir -p $W/ipsw && cd $W/ipsw
unzip -o -q "$IPSW" 087-86698-044.dmg 087-86593-047.dmg 087-86715-047.dmg \
	Firmware/all_flash/DeviceTree.d22ap.im4p BuildManifest.plist
ls -l $W/ipsw $W/ipsw/Firmware/all_flash
log done
