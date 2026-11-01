#!/bin/bash
# 0274: a program that keeps crashing is not started again this boot.
set -euo pipefail
cd /opt/work/tree
git diff --quiet || { echo "tree dirty"; exit 1; }
python3 /mnt/d/workbuddy/ios/data-a-live-main/wsl/fix_0274.py
git add -A
git diff --cached --stat
git diff --cached > /mnt/d/workbuddy/ios/data-a-live-main/xnu/patches/0274-crash-stop.patch
git -c user.name=t -c user.email=t@t commit -qm 0274
