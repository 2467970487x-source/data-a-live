#!/bin/bash
# 0182: chip id with slices for Turnip; file installer up to 64 MiB in chunks.
set -euo pipefail
cd /opt/work/tree
git diff --quiet || { echo "tree dirty"; exit 1; }
python3 /mnt/d/workbuddy/ios/data-a-live-main/wsl/fix_0182.py
git add -A
git diff --cached --stat
git diff --cached > /mnt/d/workbuddy/ios/data-a-live-main/xnu/patches/0182-pandora-gpu-chipid-files-chunks.patch
git -c user.name=t -c user.email=t@t commit -qm 0182
