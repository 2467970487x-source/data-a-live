#!/bin/bash
# 0302: the Codec channels, as iPhone X describes them.
set -euo pipefail
cd /opt/work/tree
git diff --quiet || { echo "tree dirty"; exit 1; }
python3 /mnt/d/workbuddy/ios/data-a-live-main/wsl/fix_0302.py
git add -A
git diff --cached --stat
git diff --cached > /mnt/d/workbuddy/ios/data-a-live-main/xnu/patches/0302-audio-codec-channels.patch
git -c user.name=t -c user.email=t@t commit -qm 0302
