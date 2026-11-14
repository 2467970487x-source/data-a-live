#!/usr/bin/env python3
"""Rebuild a PANDFW01 pack: replace entries by name, add new ones, keep the rest byte-identical.

  rebuild_pack.py BASE.img OUT.img NAME=PATH [NAME=PATH ...] [--drop NAME]

Layout (mkfwpack2.py): block 0 = "PANDFW01" | u32 count | u32 reserved, then
count x {char name[48]; u64 off; u64 size}, every body 4 KiB aligned.
"""
import struct
import sys

ALIGN = 4096
HEADER = 16
ENTRY = 64


def read_pack(path):
    src = open(path, "rb").read()
    if src[:8] != b"PANDFW01":
        raise SystemExit(f"{path}: not a PANDFW01 pack")
    count = struct.unpack_from("<I", src, 8)[0]
    entries = []
    for i in range(count):
        e = src[HEADER + i * ENTRY:HEADER + (i + 1) * ENTRY]
        name = e[:48].split(b"\0")[0].decode()
        off, size = struct.unpack_from("<QQ", e, 48)
        entries.append((name, src[off:off + size]))
    return entries


def write_pack(path, entries):
    body_start = HEADER + ENTRY * len(entries)
    body_start = (body_start + ALIGN - 1) // ALIGN * ALIGN
    blobs, offsets, cursor = [], [], body_start
    for name, data in entries:
        offsets.append(cursor)
        blobs.append(data)
        cursor = (cursor + len(data) + ALIGN - 1) // ALIGN * ALIGN
    out = bytearray(cursor)
    out[0:8] = b"PANDFW01"
    struct.pack_into("<II", out, 8, len(entries), 0)
    for i, (name, data) in enumerate(entries):
        raw = name.encode()[:47]
        out[HEADER + i * ENTRY:HEADER + i * ENTRY + len(raw)] = raw
        struct.pack_into("<QQ", out, HEADER + i * ENTRY + 48, offsets[i], len(data))
        out[offsets[i]:offsets[i] + len(data)] = data
    open(path, "wb").write(bytes(out))
    return cursor


if __name__ == "__main__":
    argv = sys.argv[1:]
    if len(argv) < 2:
        raise SystemExit(__doc__)
    base, out = argv[0], argv[1]
    pairs, drop = [], set()
    for a in argv[2:]:
        if a == "--drop":
            continue
        if a.startswith("--"):
            raise SystemExit(f"unknown flag {a}")
        if "=" in a:
            pairs.append(tuple(a.split("=", 1)))
        else:
            drop.add(a)

    entries = read_pack(base)
    order = [n for n, _ in entries]
    table = dict(entries)
    for name, path in pairs:
        data = open(path, "rb").read()
        if name in table:
            print(f"  replace {name:34s} {len(table[name]):>9d} -> {len(data)}")
        else:
            print(f"  add     {name:34s} {'':>9s}    {len(data)}")
            order.append(name)
        table[name] = data
    for name in drop:
        if name in table:
            print(f"  drop    {name}")
            order.remove(name)
            del table[name]

    size = write_pack(out, [(n, table[n]) for n in order])
    print(f"{out}: {len(order)} entries, {size} bytes")
