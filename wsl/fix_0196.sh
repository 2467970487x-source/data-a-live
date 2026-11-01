#!/bin/bash
# 0196: GPU frequency and bandwidth boot-args, hang check needs work pending a full tick.
set -euo pipefail
cd /opt/work/tree
git diff --quiet || { echo "tree dirty"; exit 1; }
python3 /mnt/d/workbuddy/ios/data-a-live-main/wsl/fix_0196.py
git add -A
git diff --cached --stat
git diff --cached > /mnt/d/workbuddy/ios/data-a-live-main/xnu/patches/0196-pandora-gpu-perf-vote.patch
git -c user.name=t -c user.email=t@t commit -qm 0196
