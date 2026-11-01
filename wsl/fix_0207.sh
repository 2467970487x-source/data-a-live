#!/bin/bash
# 0207: performance-controller logging fixes (thread table reuse, names after exec).
set -euo pipefail
cd /opt/work/tree
git diff --quiet || { echo "tree dirty"; exit 1; }
python3 /mnt/d/workbuddy/ios/data-a-live-main/wsl/fix_0207.py
git add -A
git diff --cached --stat
git diff --cached > /mnt/d/workbuddy/ios/data-a-live-main/xnu/patches/0207-pandora-perfctl-table.patch
git -c user.name=t -c user.email=t@t commit -qm 0207
