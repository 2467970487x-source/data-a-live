#!/bin/bash
# 0243: the battery state as Android.
set -euo pipefail
cd /opt/work/tree
git diff --quiet || { echo "tree dirty"; exit 1; }
python3 /mnt/d/workbuddy/ios/data-a-live-main/wsl/fix_0243.py
git add -A
git diff --cached --stat
git diff --cached > /mnt/d/workbuddy/ios/data-a-live-main/xnu/patches/0243-battery-as-android.patch
git -c user.name=t -c user.email=t@t commit -qm 0243
