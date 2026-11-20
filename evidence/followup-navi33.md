# Fremont's four inactive CU positions

**CONFIRMED.** The two shader engines have the same layout. Their first shader arrays expose eight compute units (CUs) each. Their second arrays expose six each. In both second arrays the missing positions are CU 6 and CU 7, the two members of workgroup processor (WGP) 3. Indices start at zero. This locates the four positions that the previous boot summary could only count. [Earlier GPU inventory](gpu.md)

| Shader engine | Shader array | Active CU mask | Inactive CU mask | Active WGP mask | Active CUs |
|---:|---:|---:|---:|---:|---:|
| 0 | 0 | `0xff` | `0x00` | `0xf` | 8 |
| 0 | 1 | `0x3f` | `0xc0` | `0x7` | 6 |
| 1 | 0 | `0xff` | `0x00` | `0xf` | 8 |
| 1 | 1 | `0x3f` | `0xc0` | `0x7` | 6 |

## Where the masks come from

The read-only follow-up on November 20, 2026 UTC used an ordinary login on Fremont board 9, BIOS F7F0108, kernel `7.2.7-valve2-2-neptune-72-g31504582a073`. The PCI device at `0000:03:00.0` is `1002:7481`, subsystem `1e44:1717`, PCI revision `c7`. Its cached discovery record gives GC hardware ID 11, instance 0, version 11.0.2, harvest `0x0`, with four base entries `0x1260, 0xa000, 0x1c000, 0x02402c00`. Those are discovery register-base values. The GC harvest field describes the entire IP instance.

1. KFD node 1 reports gfx target `110002`, one XCC, four shader arrays, two arrays per shader engine, eight CU slots per array, 56 SIMDs and two SIMDs per CU.
2. Its four 256 KiB L1 cache entries, indices 56–59 on this boot, have first processor IDs at offsets 0, 8, 16 and 24 from `simd_id_base`. Their low-order sibling bits are eight ones, six ones, eight ones and six ones. All higher bits are zero. SHA-256 of the four complete `properties` text files concatenated in that order is `dc357afdac8cd141b5570cacbea0a714fbe6e78a062b5fc7958bf67b4664d10c`.
3. In Linux v7.2, KFD walks shader engines, arrays and CU slots in that order. It reports each L1 sibling map relative to the first active CU in that cache. The collector restores that origin using `processor_id_low`, unions the L1 entries, and checks the total against the SIMD count. This also handles an array whose lowest-numbered pair is missing. The boot journal independently prints `SE 2, SH per SE 2, CU per SH 8, active_cu_number 28`. Both kernel interfaces ultimately use AMDGPU's topology. [KFD cache construction](https://github.com/torvalds/linux/blob/8d3ae59288f1e7d58d76558a6ee96d533bc5019f/drivers/gpu/drm/amd/amdkfd/kfd_topology.c#L1614-L1668) · [Engine and array iteration](https://github.com/torvalds/linux/blob/8d3ae59288f1e7d58d76558a6ee96d533bc5019f/drivers/gpu/drm/amd/amdkfd/kfd_topology.c#L1810-L1853)
4. On GFX11 the driver combines the hardware and user inactive-WGP fields, inverts the result within the supported width, and expands each active WGP to two adjacent CU bits. The exposed `disable_cu` module parameter reads `(null)` on this boot. These observations establish the **effective** masks. Their decomposition into manufacturing configuration and firmware policy is **UNKNOWN**. [GFX11 mask construction and CU counting](https://github.com/torvalds/linux/blob/8d3ae59288f1e7d58d76558a6ee96d533bc5019f/drivers/gpu/drm/amd/amdgpu/gfx_v11_0.c#L7530-L7618)

The live journal also reports ATOM BIOS `113-D7461000-101` build `00171149`, DMUB `0x07002D00` and VCN ENC 1.23 / DEC 9 / VEP 0 / revision 16. The earlier collection records SMU firmware 82.92.0. These identify the firmware context. None assigns a reason to the two inactive WGPs. The revision of the die mask remains **UNKNOWN**. [GPU and firmware evidence](gpu.md)

The SHA-256 of the installed, decompressed Fremont `amdgpu.ko` was `990f7525b2325a617ecdf8e3cde2669d011c35b4e8735a6732a1902664855a02`, matching Valve’s distributed module. At the source commit matching the kernel build suffix, Neptune's entire `kfd_topology.c` matches upstream v7.2 (SHA-256 `eaf97cd32b63bfcba0da7aa9adf3f76e1bba8e61179b7c921644f67abd0ed804`). The only diff in `gfx_v11_0.c` changes firmware-version thresholds for user queues. The WGP mask construction and CU counting functions are identical. [Matching Neptune GFX11 source](https://github.com/Jovian-Experiments/linux/blob/31504582a07316ae0e8a8fb3b8fdc39d94842816/drivers/gpu/drm/amd/amdgpu/gfx_v11_0.c#L7530-L7618) · [Valve kernel package](https://steamdeck-packages.steamos.cloud/archlinux-mirror/jupiter-3.9/os/x86_64/linux-neptune-72-7.2.7.valve2-2-x86_64.pkg.tar.zst)

## Commercial comparison

**CONFIRMED.** Valve specifies 28 CUs for the Steam Machine. AMD specifies 28 CUs and 1,792 shader processors for both the RX 7600M and RX 7600S. The RX 7600M XT and RX 7700S have 32 CUs and 2,048 shader processors. A 28-CU count is therefore an existing commercial configuration. The claim that the **count** is unique to Valve is **DISPROVEN**. AMD's published specifications give totals. They supply no per-array masks to match against these four rows. A Valve-specific mask pattern, identical masking across retail boards, individual CU health and recovery all remain **UNKNOWN**. [AMD mobile Radeon product table](https://www.amd.com/content/dam/amd/en/documents/partner-hub/radeon/amd-radeon-rx-7000-series-laptops-quick-reference.pdf) · [Valve hardware specifications](https://store.steampowered.com/hardware/steammachine)

## Comparison with published devices

**CONFIRMED for the published observations.** A commercial RX 7600S owner reports the same aggregate topology as Fremont on an ASUS FA617NS. A separate Fremont owner identifies Navi 33 on their board. Neither publication includes per-array CU masks. Mesa supplies a four-mask **32-CU control** for the same GPU family. A matching 28-CU mask on a second device remains **UNKNOWN**.

| Evidence | GPU identification and observable topology | Can it distinguish the position of the inactive WGPs? |
|---|---|---|
| This Fremont | `1002:7481`, PCI `c7`. KFD L1 sibling maps give `ff/3f` and `ff/3f`, count 28. | Yes, for this board and boot. The two second arrays each lack positions 6 and 7. |
| ASUS FA617NS, RX 7600S | The owner's post identifies RADV NAVI33 and `1002:7480`. The boot log records two engines, two arrays per engine, eight positions per array, 28 active CUs. The separate integrated GPU reports 12. | The provided boot line contains only the total. Both the per-array distribution and WGP indices are unavailable. [Original May 2024 capture](https://forum.garudalinux.org/t/can-no-longer-see-dedicated-gpu-works-on-live-garuda-usb-relevant-logs-attached/36886/1) |
| Second Fremont, published owner inventory | OpenGL identifies radeonsi Navi 33 and the Vulkan device list identifies RADV NAVI33 on a different kernel build. At pinned commit `0a9aa1e8b9eea6fa7fb755e2583b0accfff43bdc`, these files are 1,264 and 2,166 bytes. | Neither file includes KFD sibling maps, DRM CU bitmaps or four Mesa CU-mask rows. [OpenGL capture](https://github.com/ATRoUko/steam-machine-hardware-reference/blob/0a9aa1e8b9eea6fa7fb755e2583b0accfff43bdc/terminal/07_graphics.txt) · [Vulkan capture](https://github.com/ATRoUko/steam-machine-hardware-reference/blob/0a9aa1e8b9eea6fa7fb755e2583b0accfff43bdc/terminal/08_vulkan.txt) |
| Mesa's recorded Navi 33 device profile | `1002:7480`, PCI `cf`, `cu_active_number=32`, four meaningful `cu_bitmap` entries `ff/ff` and `ff/ff`. | Yes, for this software fixture. It supplies the full-width reference and has four more active CUs than the sampled Fremont. Its PCI ID also occurs on the 28-CU ASUS. [Mesa source at the inspected commit](https://github.com/chaotic-cx/mesa-mirror/blob/edc15313ddb0f03815cf91a1ac238b8be0782022/src/amd/common/amdgpu_devices.c#L2581-L2598) |

For reproduction, the ASUS post is available as Discourse JSON. SHA-256 of the first post's `cooked` UTF-8 field, before HTML unescaping, is `253d4569ff7de084f19e3a0744caa7e612ffa869ac2c7263ecaac71dec954c87`. The two second-Fremont files hash to `9a3d748480a7d3a77d79d0a6cd2af147bb42a41a329b52e159da09ad6c2c3031` and `66c44bca1da2dde3642c71cec2be3db1fbdefcd82e6a36589f8f83f6142cf676` respectively. To compare an existing Mesa dump, look for four `cu_mask[SE…][SA…]` rows. Mesa prints a separate `CU_EN` field on those lines. An existing KFD snapshot works with the collector below. No new GPU was queried in this follow-up. [Original JSON](https://forum.garudalinux.org/t/can-no-longer-see-dedicated-gpu-works-on-live-garuda-usb-relevant-logs-attached/36886.json) · [Mesa's row definitions](https://github.com/chaotic-cx/mesa-mirror/blob/edc15313ddb0f03815cf91a1ac238b8be0782022/src/amd/common/ac_gpu_info.c#L2166-L2174)

## Reproduce from cached topology

Run this with Python 3.10 or newer on a Fremont with a single-XCC gfx1102 KFD node, or point it at a saved copy of that node's `properties` file and `caches/` directory. The collector only reads text. It prints the four rows without opening a GPU device or submitting work. [Collector](../scripts/read-kfd-cu-masks.py)

```sh
python3 scripts/read-kfd-cu-masks.py /sys/class/kfd/kfd/topology/nodes/1
```
