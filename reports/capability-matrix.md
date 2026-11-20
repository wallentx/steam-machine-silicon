# Fremont board 9 capability matrix

| Hardware block | Physical presence | OS visibility / firmware initialization | Driver support | Disable mechanism / permanence | Confidence |
|---|---|---|---|---|---|
| CPU integrated graphics | Likely retained from APU design | GP17.VGA maps to 07:00.0 instrumentation dummy, no graphics endpoint | amdgpu present, no CPU graphics binding | Product-level report of fuse disablement, likely permanent | STRONG EVIDENCE |
| XDNA | Unknown, unlikely from 8540U comparison | IPU AML address only, 08:00.1 absent, no probe | amdxdna available incl. 1022:1502 | No observed gating mechanism | CONFIRMED no enumerated XDNA, UNKNOWN physical presence |
| Additional CPU cores | Unknown, no evidence beyond six | Six cores, twelve threads | Linux SMP active | No core harvesting demonstrated | UNKNOWN |
| Additional dGPU CUs | Four architectural positions beyond active count | 28 of 32 active | amdgpu/KFD | Harvested configuration likely, reason and viability unknown | CONFIRMED counts |
| CPU audio DSP / ACP | Unknown | GP17.ACP, power methods and children, 07:00.5 empty. HD Audio at 07:00.6 active | ACP requires matching hardware, HDA bound separately | Unknown | CONFIRMED firmware description, UNKNOWN physical DSP |
| Discrete VCN/JPEG/SDMA | Present | VCN unified, JPEG decode, two SDMA rings initialized | amdgpu | Active | CONFIRMED |
| CPU-side video engines | Unknown | No integrated DRM node or CPU-side GC discovery | No bound media path | Unknown | UNKNOWN |
| CPU PSP/CCP | Present | 07:00.2 encryption controller | ccp bound | Active | CONFIRMED |
| CVIP/CVPE or another vision engine | Unknown | No attributed endpoint | Unknown | Unknown | UNKNOWN |

Only the enumerated engines have a demonstrated Linux access path. The hypothetical uses are integrated graphics/media, NPU inference, ACP audio processing, and extra CPU/GPU throughput respectively. No observations establish that software can expose any of the unavailable blocks. See the [CPU](../evidence/cpu.md), [NPU](../evidence/npu.md), [GPU](../evidence/gpu.md) and [ACPI](../evidence/acpi.md) records for commands, identifiers and limits.
