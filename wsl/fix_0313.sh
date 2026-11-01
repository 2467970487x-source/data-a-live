#!/bin/bash
# 0313: user call stacks of every thread of named processes (pandora_stacks=NAME,...).
set -euo pipefail
cd /opt/work/tree
git diff --quiet || { echo "tree dirty"; exit 1; }
python3 /mnt/d/workbuddy/ios/data-a-live-main/wsl/fix_0313.py
git add -A
git diff --cached --stat
git diff --cached > /mnt/d/workbuddy/ios/data-a-live-main/xnu/patches/0313-thread-stacks.patch
git -c user.name=t -c user.email=t@t commit -qm 0313
