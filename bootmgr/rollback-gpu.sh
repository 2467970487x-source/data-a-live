#!/bin/bash
# Back out tonight's GPU attempt: the display-only loader goes back into the slot, and the
# firmware pack's header is zeroed so the file installer does nothing on the next iOS boot
# (a pack with content but a kernel without pandora_gpu would have backboardd load the Metal
# plugin with no GPU device behind it).
#
#   bootmgr/rollback-gpu.sh           check only, writes nothing
#   bootmgr/rollback-gpu.sh --yes     do it (phone in Android with root, adb connected)
set -euo pipefail
export MSYS_NO_PATHCONV=1
B="$(cd "$(dirname "$0")" && pwd)"
ADB=/d/Android/platform-tools/adb.exe
yes=
[ "${1:-}" = "--yes" ] && yes=1
[ "$("$ADB" shell getprop ro.product.device | tr -d '\r')" = pandora ] || { echo "no pandora on adb"; exit 1; }
su() { "$ADB" shell su -c "'$*'" | tr -d '\r'; }

echo "== firmware pack header"
if [ -n "$yes" ]; then
	winp() { cygpath -w "$1"; }
	T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
	python -I -c "open(r'$(winp "$T/blank.bin")','wb').write(b'\0'*4096)"
	"$ADB" push "$(winp "$T/blank.bin")" /data/local/tmp/blank.bin > /dev/null
	# The guard checks the pinned file's extents, not its content: one page in place keeps it armed.
	su "chattr -i /data/local/tmp/adspfw.img"
	su "/data/local/tmp/pinfile rawwrite /data/local/tmp/adspfw.img \$(readlink -f /dev/block/by-name/userdata) 1 --yes < /data/local/tmp/blank.bin" | tail -1
	su "chattr +i /data/local/tmp/adspfw.img; rm /data/local/tmp/blank.bin"
	echo "header cleared"
else
	echo "not written"
fi

echo "== slot"
bash "$B/update_ios.sh" --loader "$B/../shim/loader/out/loader-fill.img" ${yes:+--yes} 2>&1 | tail -6
