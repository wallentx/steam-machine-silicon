#!/usr/bin/env bash
# Ordinary-user snapshot. Output only allowlisted platform and device fields.
set -eu
export LC_ALL=C
uname -srvm
grep -E '^(NAME|BUILD_ID|VERSION_ID)=' /etc/os-release
for field in product_family product_name product_version board_vendor board_name board_version bios_vendor bios_version bios_date ec_firmware_release; do
  printf '%s %s\n' "$field" "$(cat "/sys/class/dmi/id/$field")"
done
for dev in /sys/bus/pci/devices/*; do
  printf '%s %s:%s rev=%s class=%s sub=%s:%s driver=%s\n' "$(readlink -f "$dev")" "$(cat "$dev/vendor")" "$(cat "$dev/device")" "$(cat "$dev/revision")" "$(cat "$dev/class")" "$(cat "$dev/subsystem_vendor")" "$(cat "$dev/subsystem_device")" "$(basename "$(readlink "$dev/driver" || echo unbound)")"
done
lsmod
if [[ -r /proc/config.gz ]]; then
  zgrep -E '^CONFIG_(ACPI|DEBUG_FS|DRM_AMDGPU|DRM_ACCEL|DRM_ACCEL_AMDXDNA|SND_SOC_AMD[^=]*)=' /proc/config.gz
fi
modinfo -F alias amdxdna
