#!/usr/bin/env python3
"""Extend an existing PANDFW01 pack with more files, keeping the old entries byte-identical.

  mkfwpack2.py OLD.img OUT.img NAME=PATH [NAME=PATH ...]

The kernel (bsd/dev/pandora_wifi_deps.c) looks a firmware file up by its full
name, so NAME may contain a directory part ("peach/amss20.bin") even though the
pack is flat.  Layout: block 0 = "PANDFW01" | u32 count | u32 reserved |
count x {char name[48]; u64 off; u64 size}, every body 4 KiB aligned.
"""
import struct
import sys

old, out = sys.argv[1], sys.argv[2]
pairs = [a.split('=', 1) for a in sys.argv[3:]]

src = open(old, 'rb').read()
if src[:8] != b'PANDFW01':
    sys.exit(f'{old}: not a PANDFW01 pack')
count = struct.unpack_from('<I', src, 8)[0]
entries = []
for i in range(count):
    e = src[16 + i * 64:16 + (i + 1) * 64]
    name = e[:48].split(b'\0')[0].decode()
    off, size = struct.unpack_from('<QQ', e, 48)
    entries.append((name, src[off:off + size]))
    print(f'  keep {name:34s} {size:>9d}')

for name, path in pairs:
    data = open(path, 'rb').read()
    if any(name == n for n, _ in entries):
        entries = [(n, data if n == name else d) for n, d in entries]
        print(f'  repl {name:34s} {len(data):>9d}')
        continue
    entries.append((name, data))
    print(f'  add  {name:34s} {len(data):>9d}')

off = 4096
blobs, dirs = [], []
for name, data in entries:
    dirs.append(struct.pack('<48sQQ', name.encode(), off, len(data)))
    pad = data + b'\0' * (-len(data) % 4096)
    blobs.append(pad)
    off += len(pad)
head = b'PANDFW01' + struct.pack('<II', len(entries), 0) + b''.join(dirs)
if len(head) > 4096:
    sys.exit(f'directory overflows block 0: {len(head)} bytes')
head += b'\0' * (4096 - len(head))
with open(out, 'wb') as o:
    o.write(head)
    for b in blobs:
        o.write(b)
print(f'{out}: {len(entries)} files, {off} bytes')
