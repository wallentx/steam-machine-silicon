# Valve Fremont, board revision 9

The strongest candidate for physically present, unused accelerator silicon is the integrated Radeon GPU. Launch engineering coverage reports fuse disablement. The CPU-side graphics ACPI node resolves to an instrumentation dummy. No physical fuse readout was obtained. A dormant XDNA array is much less likely and remains unverified.

| Observation | Interpretation |
|---|---|
| SteamOS 3.9.6 build 20261112.101, kernel 7.2.7-valve2-2-neptune-72-g31504582a073, Valve Fremont product v1, board v9, BIOS F7F0108, EC 1.7 | Matches the reported retail configuration including the PCI subsystem 1e44:1717 and separate CPU/GPU topology. Production versus development provenance for this individual board is unknown. |
| CPUID 00a70fc0, microcode 0xa70c005, six cores / twelve threads, two performance classes, shared 16 MiB L3 | AMD identifies Hawkpoint2. Ryzen 5 8540U is the closest documented comparator. Exact package ordering code and die mask remain unknown. |
| Firmware GP18.IPU describes function 08:00.1, no corresponding PCI function | Platform firmware models an IPU. No driver could bind at this address on this boot. The 8540U has no supported NPU. |
| CPU graphics function 1002:145a at 07:00.0 | Graphics unavailable, reported fuse explanation corroborated at the behavioral level. |
| dGPU 1002:7481 rev C7, gfx1102, 28 active CUs out of 32 positions | Navi 33 configuration with four unavailable CU positions. Yield, permanent fuses and software masks cannot be distinguished. |
| GP17.ACP at empty 07:00.5, with power methods | Firmware models a CPU audio coprocessor. Physical implementation unknown. Discrete VCN, JPEG and SDMA have initialized rings. |

The comparator follow-up found an identical declaration on a Framework with enumerated XDNA, and similar declarations in firmware shipped for 8540U-family products. Same-boot live AML and a complete PCI tree for one non-PRO 8540U remain missing. The most decisive physical evidence would be an AMD or Valve mapping of the 1772 identifier to a documented die floorplan and product harvest specification. [Comparator evidence](evidence/followup-comparators.md) · [Live CU masks](evidence/followup-navi33.md) · [Capability matrix](reports/capability-matrix.md)
