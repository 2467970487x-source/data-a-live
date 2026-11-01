#!/bin/bash
# 0324: GPU context faults logged as they happen.
set -euo pipefail
cd /opt/work/tree
git diff --quiet || { echo "tree dirty"; exit 1; }
python3 /mnt/d/workbuddy/ios/data-a-live-main/wsl/fix_0324.py
git add -A
git diff --cached --stat
git diff --cached > /mnt/d/workbuddy/ios/data-a-live-main/xnu/patches/0324-gpu-fault-now.patch
git -c user.name=t -c user.email=t@t commit -qm 0324
