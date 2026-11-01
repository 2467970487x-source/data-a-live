#!/bin/bash
# 0212: pandora_fbdump_swap=N, one frame dump at swap N.
set -euo pipefail
cd /opt/work/tree
git diff --quiet || { echo "tree dirty"; exit 1; }
python3 /mnt/d/workbuddy/ios/data-a-live-main/wsl/fix_0212.py
git add -A
git diff --cached --stat
git diff --cached > /mnt/d/workbuddy/ios/data-a-live-main/xnu/patches/0212-pandora-fbdump-swap.patch
git -c user.name=t -c user.email=t@t commit -qm 0212
