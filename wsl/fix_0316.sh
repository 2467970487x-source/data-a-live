#!/bin/bash
# 0316: GPU SMMU contexts continue after a fault (HUPCF).
set -euo pipefail
cd /opt/work/tree
git diff --quiet || { echo "tree dirty"; exit 1; }
python3 /mnt/d/workbuddy/ios/data-a-live-main/wsl/fix_0316.py
git add -A
git diff --cached --stat
git diff --cached > /mnt/d/workbuddy/ios/data-a-live-main/xnu/patches/0316-gpu-smmu-hupcf.patch
git -c user.name=t -c user.email=t@t commit -qm 0316
