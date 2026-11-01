#!/bin/bash
# 0161: the file installer strips CR line ends from files.txt.
set -euo pipefail
cd /opt/work/tree
git diff --quiet || { echo "tree dirty"; exit 1; }
python3 /mnt/d/workbuddy/ios/data-a-live-main/wsl/fix_0161.py
git add -A
git diff --cached --stat
git diff --cached > /mnt/d/workbuddy/ios/data-a-live-main/xnu/patches/0161-pandora-files-crlf.patch
git -c user.name=t -c user.email=t@t commit -qm 0161
