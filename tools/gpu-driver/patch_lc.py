#!/usr/bin/env python3
"""Add one LC_LOAD_DYLIB to a Mach-O and leave everything else byte for byte alone.

    patch_lc.py <macho> <dylib-path-in-bundle>

The driver binary keeps 0xe58 .. 0x4000 of __TEXT empty (no section claims it), so a new
load command fits without moving any section.  Anchored at @loader_path so the library is
found inside the bundle, the way the bundle itself is found.
"""
import struct
import sys

LC_LOAD_DYLIB = 0x0C
MH_MAGIC_64 = 0xFEEDFACF
SIZEOF_CMDS_OFF = 20          # ncmds at 16, sizeofcmds at 20
HEADER = 32


def add_dylib(path: str, name: str) -> tuple:
    data = bytearray(open(path, "rb").read())
    magic = struct.unpack_from("<I", data, 0)[0]
    if magic != MH_MAGIC_64:
        raise SystemExit(f"{path}: not a little-endian 64-bit Mach-O (magic {magic:#x})")

    ncmds, sizeofcmds = struct.unpack_from("<II", data, 16)
    cmds_end = HEADER + sizeofcmds

    dylib_path = f"@loader_path/{name}".encode() + b"\x00"
    size = 24 + len(dylib_path)
    size = (size + 7) & ~7                      # dylib_command is 8-byte aligned
    cmd = struct.pack("<IIIIII", LC_LOAD_DYLIB, size,
                      24,                       # name offset, right after the command
                      2,                        # timestamp
                      0x00010000,               # current version
                      0x00010000)               # compatibility version
    block = cmd + dylib_path
    block += b"\x00" * (size - len(block))

    # Refuse to scribble on a section: the new command must stay inside the __TEXT hole
    if cmds_end + size > 0x4000:
        raise SystemExit(f"no room: load commands end at {cmds_end:#x}, first section at 0x4000")

    old = bytes(data[cmds_end:cmds_end + size])
    if old.strip(b"\x00"):
        raise SystemExit(f"occupied: {old[:16]!r} sits where the load command would go")

    data[cmds_end:cmds_end + size] = block
    struct.pack_into("<II", data, 16, ncmds + 1, sizeofcmds + size)
    open(path, "wb").write(data)
    return ncmds, ncmds + 1, sizeofcmds, sizeofcmds + size, cmds_end, size


if __name__ == "__main__":
    if len(sys.argv) != 3:
        raise SystemExit(__doc__)
    target, lib = sys.argv[1], sys.argv[2]
    n0, n1, s0, s1, at, size = add_dylib(target, lib)
    print(f"LC_LOAD_DYLIB @loader_path/{lib} written at {at:#x} ({size} bytes)")
    print(f"ncmds {n0} -> {n1}, sizeofcmds {s0:#x} -> {s1:#x}")
