#!/bin/bash
# 0205: performance-controller signals, SoC temperatures, all SCMI levels (logging only).
set -euo pipefail
cd /opt/work/tree
git diff --quiet || { echo "tree dirty"; exit 1; }
python3 /mnt/d/workbuddy/ios/data-a-live-main/wsl/fix_0205.py
git add -A
git diff --cached --stat
git diff --cached > /mnt/d/workbuddy/ios/data-a-live-main/xnu/patches/0205-pandora-perfctl-signals.patch
git -c user.name=t -c user.email=t@t commit -qm 0205
