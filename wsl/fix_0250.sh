#!/bin/bash
# 0250: map the USB module windows first.
set -euo pipefail
cd /opt/work/tree
git diff --quiet || { echo "tree dirty"; exit 1; }
python3 /mnt/d/workbuddy/ios/data-a-live-main/wsl/fix_0250.py
git add -A
git diff --cached --stat
git diff --cached > /mnt/d/workbuddy/ios/data-a-live-main/xnu/patches/0250-usb-map-first.patch
git -c user.name=t -c user.email=t@t commit -qm 0250
