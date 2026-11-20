# Steam Machine silicon result

AMD identifies the observed 19h/7Ch/0 signature as Hawkpoint2. The Ryzen 5 8540U is the closest commercial comparison and lacks a supported NPU. Fremont firmware explicitly names an IPU at 08:00.1. The device does not enumerate and the installed amdxdna driver has nothing to bind. Physical XDNA presence remains unknown.

Product reporting describes the integrated GPU as fused off, and firmware links the integrated graphics node to a dummy PCI function. The separate Navi 33 exposes 28 active CUs across 32 architectural positions plus initialized driver paths for VCN, JPEG and SDMA. The follow-up located the two inactive WGPs in the second shader array of each engine. Their physical health remains unknown. [Live CU masks](../evidence/followup-navi33.md)

Fremont's 13-byte IPU declaration exactly matches the one on a Framework with enumerated XDNA. Two 8540U-family firmware images describe a similar child. Shared firmware explains the name without requiring a physically present Fremont NPU. [Follow-up results, negative controls and next experiments](followup-summary.md)

[Findings](../findings.md) · [Capability matrix](capability-matrix.md) · [Firmware namespace](../evidence/acpi.md)
