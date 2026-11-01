#!/bin/bash
# 0257: limits from the body temperature.
set -euo pipefail
cd /opt/work/tree
git diff --quiet || { echo "tree dirty"; exit 1; }
python3 /mnt/d/workbuddy/ios/data-a-live-main/wsl/fix_0257.py
git add -A
git diff --cached --stat
git diff --cached > /mnt/d/workbuddy/ios/data-a-live-main/xnu/patches/0257-therm-limits.patch
git -c user.name=t -c user.email=t@t commit -qm 0257
