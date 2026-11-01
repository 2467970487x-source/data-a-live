#!/bin/bash
# 0158: disk statistics every 30 s in the log (pandora_iostats).
set -euo pipefail
cd /opt/work/tree
git diff --quiet || { echo "tree dirty"; exit 1; }
python3 /mnt/d/workbuddy/ios/data-a-live-main/wsl/fix_0158.py
git add -A
git diff --cached --stat
git diff --cached > /mnt/d/workbuddy/ios/data-a-live-main/xnu/patches/0158-pandora-io-stats.patch
git -c user.name=t -c user.email=t@t commit -qm 0158
