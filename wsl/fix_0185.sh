#!/bin/bash
# 0185: file installer makes directories (pandora_mkdir).
set -euo pipefail
cd /opt/work/tree
git diff --quiet || { echo "tree dirty"; exit 1; }
python3 /mnt/d/workbuddy/ios/data-a-live-main/wsl/fix_0185.py
git add -A
git diff --cached --stat
git diff --cached > /mnt/d/workbuddy/ios/data-a-live-main/xnu/patches/0185-pandora-files-mkdir.patch
git -c user.name=t -c user.email=t@t commit -qm 0185
