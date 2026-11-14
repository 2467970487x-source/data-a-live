"""Edit the boot-args inside a loader image (shim/loader/out/loader-boot.img) or its Image.

    python -I tools/set_bootargs.py IN OUT [--list] [--set KEY=VALUE]... [--del KEY]...

IN       a boot image (ANDROID!) or a bare arm64 Image with a SWEETXNU payload
OUT      where the edited copy goes (never the same file as IN)
--list   print the boot-args and stop
--set    replace KEY with VALUE (appended when KEY is absent)
--del    drop KEY and everything left of its '=' (KLIST may be given several times)

The payload holds the boot-args in a fixed 608-byte field, so a shorter line is fine and a
longer one only needs to stay under BOOT_LINE_LENGTH. Nothing else in the image moves: the
result boots exactly like IN, which is what bootmgr/update_ios.sh --loader expects.
"""
import struct
import sys

PAGE = 4096
BOOT_LINE_LENGTH = 608
PAYLOAD_ARGS = 72          # SWEETXNU header (see bootmgr/slot.py): boot-args at +72


def image_of(data):
    """The arm64 Image inside a boot image, as (bytes, offset_of_image_in_file)."""
    if data[:8] == b'ANDROID!':
        ksize = struct.unpack_from('<I', data, 8)[0]
        v = struct.unpack_from('<I', data, 40)[0]
        if v not in (3, 4):
            sys.exit(f'boot header v{v}: only v3/v4 expected')
        return data[PAGE:PAGE + ksize], PAGE
    return data, 0


def payload_offset(img):
    offs = [o for o in range(0, len(img), PAGE) if img[o:o + 8] == b'SWEETXNU']
    if len(offs) != 1:
        sys.exit(f'{len(offs)} SWEETXNU payloads found, expected 1')
    return offs[0]


def main():
    sets, dels, show, rest = [], [], False, []
    argv = sys.argv[1:]
    while argv:
        a = argv.pop(0)
        if a == '--list':
            show = True
        elif a == '--set':
            sets.append(argv.pop(0))
        elif a == '--del':
            dels.append(argv.pop(0))
        elif a.startswith('--'):
            sys.exit(f'unknown option {a}')
        else:
            rest.append(a)
    if len(rest) != 2:
        sys.exit(__doc__)
    src, dst = rest
    if src == dst:
        sys.exit('OUT must differ from IN')

    raw = open(src, 'rb').read()
    img, base = image_of(raw)
    pl = payload_offset(img)
    at = pl + PAYLOAD_ARGS
    words = img[at:at + BOOT_LINE_LENGTH].split(b'\0')[0].decode().split()
    before = list(words)

    for key in dels:
        words = [w for w in words if w.split('=', 1)[0] != key]
    for item in sets:
        if '=' not in item:
            sys.exit(f'--set needs KEY=VALUE, got {item!r}')
        key = item.split('=', 1)[0]
        words = [w for w in words if w.split('=', 1)[0] != key]
        words.append(item)

    line = ' '.join(words).encode()
    if len(line) >= BOOT_LINE_LENGTH:
        sys.exit(f'boot-args {len(line)} bytes, room for {BOOT_LINE_LENGTH - 1}')
    if show or not sets and not dels:
        for w in before:
            print('   ', w)
        print(f'{len(before)} words, {len(" ".join(before))} bytes')
        if not dst:
            return
    if not (sets or dels):
        return

    out = bytearray(img)
    out[at:at + BOOT_LINE_LENGTH] = line + b'\0' * (BOOT_LINE_LENGTH - len(line))
    buf = bytearray(raw)
    buf[base:base + len(out)] = out
    open(dst, 'wb').write(bytes(buf))
    print(f'{src} -> {dst}')
    print('boot-args:', line.decode())
    print(f'{len(before)} -> {len(words)} words, {len(line)} bytes')


if __name__ == '__main__':
    main()
