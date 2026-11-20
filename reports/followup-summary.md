# Fremont follow-up

**The IPU declaration gives no positive board-specific evidence of dormant XDNA.** Fremont's entire IPU device definition is the same 13 AML bytes as on a Framework Laptop 16 that enumerates `1022:1502`. On this Fremont, the same bridge exposes only the `1022:14ec` dummy function. Shared firmware for Dell 8540U and Lenovo PRO 8540U models also describes a function at that address. This is **STRONG EVIDENCE** that ordinary platform firmware explains the declaration. Physical XDNA presence remains **UNKNOWN**. [PCI, AML, BIOS and workload controls](../evidence/followup-comparators.md)

**The four inactive GPU positions can now be located.** On the live Fremont, each of the two shader engines reports CU masks `0xff` and `0x3f`. CU 6 and CU 7 of its second array form one inactive workgroup processor. That accounts for 28 active CUs across 32 slots. AMD's RX 7600M and RX 7600S also have 28 CUs. The count is a commercial configuration. Its exact mask pattern and the health of the excluded silicon remain unresolved across products. [Live topology, source and reproduction](../evidence/followup-navi33.md)

## What changed in the comparison

| Lead | Evidence and limit |
|---|---|
| CPU iGPU and ACP | Fremont has a graphics placeholder at `07:00.0` and no audio coprocessor at `07:00.5`. Framework has a bound ACP despite the same two ACP power-method calls. Canonical's exact non-PRO 8540U certification records a real iGPU at `1002:1901`. Product reporting favors a fused-off Fremont iGPU. This unit supplied no fuse measurement. [Hardware comparisons](../evidence/followup-comparators.md) |
| What counts as a positive XDNA control | Framework supplies a PCI device and resources. A separate 8845HS owner reports a passed accelerator workload. The Lenovo 1.05 PRO 8540U boot supplies the negative PCI control. Its matching BIOS contains the NPU child, but the OEM ID differs between the capsule template and installed DSDT. A same-boot non-PRO 8540U AML and complete PCI pair is still missing. [Primary evidence and limitations](../evidence/followup-comparators.md) |
| How the Deck differs | The LCD Deck has an ISP3 discovery record, a SATA harvest entry and CVIP power-policy code. Its PCI capture lacks the ML2 CVIP endpoint. ML2 supplies a real ISP3 driver and a C5 hand-detection job. The identity of Mero ID 254 and physical CVIP presence on the Deck remain unknown. [Deck investigation](https://github.com/wallentx/steam-deck-silicon) |

## Ranked next experiments

| Rank and action | Expected information gain | Feasibility and prerequisites | Risk / read-only |
|---|---|---|---|
| 1. Pair full PCI and ACPI captures from one non-PRO 8540U boot | High for whether the negative product actually installs the same address-only AML. | Needs an identified system, exact BIOS version and access to saved DSDT/SSDT and PCI data. | Offline comparison / yes |
| 2. Compare four CU masks on a second retail Fremont and a 28-CU mobile Radeon | High for whether this arrangement recurs, limited for fuse cause. | High with owner-provided KFD node snapshots. The included reader accepts saved files. [Collector](../scripts/read-kfd-cu-masks.py) | Cached text only / yes |
| 3. Compare the exact Valve part with a documented AMD mask and board configuration | Decisive for XDNA/iGPU presence if the records identify the actual die and its configuration. | Requires a primary AMD or Valve record tied to the Valve part. CPUID alone cannot select the die mask. | Document inspection / yes |

The follow-up read the online board's cached sysfs topology, boot journal, installed module and existing AML capture. No PCI configuration writes, register access, driver loading or accelerator workloads were required.
