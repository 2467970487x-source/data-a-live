#!/usr/bin/env bash
#
# Restore the last known-good state: lock screen comes up, black bars fixed.
#
#   boot_b   = shim/loader/out/loader-fill.img   (no GPU node at all)
#   adspfw   = work/gpu/fix2-pack.img            (NativeAdrenoMetal.bundle blanked)
#
# Why the bundle has to be blanked: Metal enumerates /System/Library/Extensions/*.bundle
# during early boot and instantiates NSPrincipalClass (NativeAdrenoMetalDevice).  While the
# accelerator cannot serve it, that hangs and backboardd freezes after four frames
# ("SWEET FB: swap 4").  Blanking Info.plist makes the scan skip the bundle; blanking the
# binary keeps it from being dlopen()ed by anything else.
#
# Usage: bash bootmgr/restore-lockscreen.sh [--yes]
#
set -u

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/.." && pwd)"
ROOT="$(cd "$REPO/.." && pwd)"

LOADER="$REPO/shim/loader/out/loader-fill.img"
PACK="$ROOT/work/gpu/fix2-pack.img"

[ -f "$LOADER" ] || { echo "missing loader: $LOADER" >&2; exit 1; }
[ -f "$PACK" ]   || { echo "missing pack:   $PACK" >&2; exit 1; }

BLOCKS=$(( ( $(wc -c < "$PACK") + 4095 ) / 4096 ))

echo "loader : $LOADER"
echo "pack   : $PACK ($(wc -c < "$PACK") bytes, $BLOCKS blocks)"
if [ "${1:-}" != "--yes" ]; then
	printf 'continue? [y/N] '
	read -r ans
	[ "$ans" = "y" ] || [ "$ans" = "Y" ] || exit 1
fi

echo "== flashing loader into boot_b =="
bash "$HERE/update_ios.sh" --loader "$LOADER" --keep-args --yes || exit 1

echo "== writing pack into adspfw area =="
export MSYS_NO_PATHCONV=1
adb push "$PACK" /data/local/tmp/fix2.bin >/dev/null || exit 1
adb shell su -c "'chattr -i /data/local/tmp/adspfw.img'"
adb shell su -c "'/data/local/tmp/pinfile rawwrite /data/local/tmp/adspfw.img \$(readlink -f /dev/block/by-name/userdata) $BLOCKS --yes < /data/local/tmp/fix2.bin'" | tail -2
adb shell su -c "'chattr +i /data/local/tmp/adspfw.img; rm -f /data/local/tmp/fix2.bin; echo locked'"

echo
echo "done - reboot and pick iOS. Expect the lock screen in ~66 s."
