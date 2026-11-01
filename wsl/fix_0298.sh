#!/bin/bash
# 0298: amp power follows the IO.
set -euo pipefail
cd /opt/work/tree
git diff --quiet || { echo "tree dirty"; exit 1; }
python3 /mnt/d/workbuddy/ios/data-a-live-main/wsl/fix_0298.py
git add -A
git diff --cached --stat
git diff --cached > /mnt/d/workbuddy/ios/data-a-live-main/xnu/patches/0298-amp-power.patch
git -c user.name=t -c user.email=t@t commit -qm 0298
