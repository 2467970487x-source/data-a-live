#!/bin/bash
# 0235: the amplifiers DSP firmware over I2C, read back.
set -euo pipefail
cd /opt/work/tree
git diff --quiet || { echo "tree dirty"; exit 1; }
python3 /mnt/d/workbuddy/ios/data-a-live-main/wsl/fix_0235.py
git add -A
git diff --cached --stat
git diff --cached > /mnt/d/workbuddy/ios/data-a-live-main/xnu/patches/0235-amp-dsp-firmware.patch
git -c user.name=t -c user.email=t@t commit -qm 0235
