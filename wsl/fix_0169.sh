#!/bin/bash
# 0169: Adreno 840 bring-up level 8, GX on (pandora_gpu=8).
set -euo pipefail
cd /opt/work/tree
git diff --quiet || { echo "tree dirty"; exit 1; }
python3 /mnt/d/workbuddy/ios/data-a-live-main/wsl/fix_0169.py
git add -A
git diff --cached --stat
git diff --cached > /mnt/d/workbuddy/ios/data-a-live-main/xnu/patches/0169-pandora-gpu-gx-on.patch
git -c user.name=t -c user.email=t@t commit -qm 0169
