#!/usr/bin/env bash
# Run as the ordinary user. --tables uses sudo only to copy cached AML.
set -eu
umask 077
root=$(cd "$(dirname "$0")/.." && pwd)
for node in /sys/bus/acpi/devices/*; do
    [[ -r $node/path ]] || continue
    name=$(cat "$node/path")
    case "$name" in
        *GP1[789]*|*GPP0*VGA*) printf '%s ' "$name"
            [[ ! -r $node/adr ]] || tr '\n' ' ' < "$node/adr"
            readlink "$node/physical_node" || echo ;;
    esac
done
if [[ ${1:-} == --tables ]]; then
    out=$(mktemp -d "$root/raw/acpi-XXXXXX")
    for table in /sys/firmware/acpi/tables/{DSDT,SSDT*}; do
        sudo -n /usr/bin/cat "$table" > "$out/${table##*/}.aml"
    done
    if command -v iasl >/dev/null; then
        (cd "$out" && iasl -da ./*.aml)
    fi
    echo "$out"
fi
# Inspect only the vendor-distributed Fremont capsule, outside the live system firmware.
capsule=/usr/share/fwupd/remotes.d/fremont/firmware/F7F0108.cab
[[ -r $capsule ]] || exit 0
python3 - "$capsule" <<'PY'
import hashlib, lzma, re, subprocess, sys
from pathlib import Path
path = Path(sys.argv[1])
print("capsule sha256", hashlib.sha256(path.read_bytes()).hexdigest())
data = subprocess.check_output(["bsdtar", "-xOf", path, "firmware.bin"])
for start in re.finditer(re.escape(bytes.fromhex("5d00000001")), data):
    decoder = lzma.LZMADecompressor(lzma.FORMAT_ALONE, memlimit=128 << 20)
    try:
        volume = decoder.decompress(data[start.start():], max_length=64 << 20)
    except lzma.LZMAError:
        continue
    for sig in re.finditer(b"DSDT|SSDT", volume):
        pos = sig.start()
        size = int.from_bytes(volume[pos+4:pos+8], "little")
        if not 36 <= size <= len(volume) - pos:
            continue
        aml = volume[pos:pos+size]
        if sum(aml) % 256 or b"IPU_" not in aml:
            continue
        ipu = aml.index(b"IPU_")
        print("LZMA offset", start.start(), "table offset", hex(pos), "size", size,
              "IPU offset", ipu, "AML", aml[ipu-3:ipu+10].hex(" "))
PY
