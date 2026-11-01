#!/bin/bash
# 0239: amp DSP start diagnostics.
set -euo pipefail
cd /opt/work/tree
git diff --quiet || { echo "tree dirty"; exit 1; }
python3 /mnt/d/workbuddy/ios/data-a-live-main/wsl/fix_0239.py
git add -A
git diff --cached --stat
git diff --cached > /mnt/d/workbuddy/ios/data-a-live-main/xnu/patches/0239-amp-start-diag.patch
git -c user.name=t -c user.email=t@t commit -qm 0239
