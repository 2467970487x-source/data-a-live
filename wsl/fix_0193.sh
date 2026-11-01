#!/bin/bash
# 0193: GPU hang dump, fence-wait timeouts counted.
set -euo pipefail
cd /opt/work/tree
git diff --quiet || { echo "tree dirty"; exit 1; }
python3 /mnt/d/workbuddy/ios/data-a-live-main/wsl/fix_0193.py
git add -A
git diff --cached --stat
git diff --cached > /mnt/d/workbuddy/ios/data-a-live-main/xnu/patches/0193-pandora-gpu-hang-dump.patch
git -c user.name=t -c user.email=t@t commit -qm 0193
