#!/bin/bash
# 0282: audio device UID Speaker.
set -euo pipefail
cd /opt/work/tree
git diff --quiet || { echo "tree dirty"; exit 1; }
python3 /mnt/d/workbuddy/ios/data-a-live-main/wsl/fix_0282.py
git add -A
git diff --cached --stat
git diff --cached > /mnt/d/workbuddy/ios/data-a-live-main/xnu/patches/0282-audio-uid-speaker.patch
git -c user.name=t -c user.email=t@t commit -qm 0282
