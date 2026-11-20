#!/usr/bin/env bash
# Print kernel-maintained GPU topology and selected boot messages.
set -eu
shopt -s nullglob
for card in /sys/class/drm/card[0-9]*; do
    [[ ${card##*/} =~ ^card[0-9]+$ ]] || continue
    dev=$card/device
    [[ -e $dev/vendor ]] || continue
    printf 'PCI %s\n' "$(basename "$(realpath "$dev")")"
    for key in vendor device subsystem_vendor subsystem_device revision mem_info_vram_total vbios_version vbios_build; do
        [[ -r $dev/$key ]] && printf '%s %s\n' "$key" "$(<"$dev/$key")"
    done
    for ip in "$dev"/ip_discovery/die/*/[A-Z]*/*; do
        [[ -f $ip/hw_id ]] || continue
        printf '%s %s.%s.%s harvest=%s\n' "${ip#*/ip_discovery/}" "$(<"$ip/major")" "$(<"$ip/minor")" "$(<"$ip/revision")" "$(<"$ip/harvest")"
    done
done
for prop in /sys/class/kfd/kfd/topology/nodes/*/properties; do
    rg '^(simd_count|simd_per_cu|array_count|simd_arrays_per_engine|cu_per_simd_array|gfx_target_version|vendor_id|device_id|num_sdma_engines) ' "$prop"
done
journalctl -k -b --no-pager -o cat | rg '^amdgpu [0-9a-f:.]+: (SE |detected ip block|\[drm\] (ATOM BIOS|Detected VRAM|RAM width|Loading DMUB)|\[VCN instance|smu driver if|ring (vcn_unified|jpeg_dec|sdma[0-9]))' | sort -u
