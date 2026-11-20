#!/usr/bin/env bash
set -eu
export LC_ALL=C
lscpu
lscpu -e=CPU,CORE,SOCKET,NODE
lscpu --caches
for f in /sys/devices/system/cpu/cpu[0-9]*/acpi_cppc/highest_perf; do
  [[ ! -r $f ]] || printf '%s %s\n' "$f" "$(<"$f")"
done
tmp=$(mktemp -d)
trap 'rm -f "$tmp/cpuid"; rmdir "$tmp"' EXIT
cc -nostdlib -shared -fPIC "$(dirname "$0")/cpuid-selected.c" -o "$tmp/cpuid"
python3 - "$tmp/cpuid" <<'PY'
import os, sys, ctypes
query = ctypes.CDLL(sys.argv[1]).query
result = (ctypes.c_uint * 4)()
for cpu in sorted(os.sched_getaffinity(0)):
    os.sched_setaffinity(0, {cpu})
    query(0x80000000, 0, result)
    maximum = result[0]
    for leaf in (0, 1, 7, 0x80000000, 0x80000001, 0x80000007, 0x80000008, 0x8000001d, 0x8000001e, 0x80000026):
        if leaf > maximum:
            continue
        for sub in range(8 if leaf in (0x8000001d, 0x80000026) else 1):
            query(leaf, sub, result)
            print(f'cpu={cpu:02d} leaf={leaf:08x} sub={sub}', *(f'{word:08x}' for word in result))
            if leaf == 0x8000001d and not result[0] & 31:
                break
            if leaf == 0x80000026 and not result[2] & 0xff00:
                break
PY
