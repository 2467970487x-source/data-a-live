#!/bin/bash
# 0221: the display's frame start interrupt (CTL0 start) for the present thread.
set -euo pipefail
cd /opt/work/tree
git diff --quiet || { echo "tree dirty"; exit 1; }
python3 /mnt/d/workbuddy/ios/data-a-live-main/wsl/fix_0221.py
git add -A
git diff --cached --stat
git diff --cached > /mnt/d/workbuddy/ios/data-a-live-main/xnu/patches/0221-pandora-frame-start-irq.patch
git -c user.name=t -c user.email=t@t commit -qm 0221
