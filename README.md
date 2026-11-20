# Inside Valve’s Steam Machine: is there an unused AI chip?

**The Steam Machine’s firmware lists an address for an AI accelerator. Whether the circuitry exists on this board is still unknown.** The clearest evidence of unused hardware concerns graphics: the integrated graphics processor is reported to be permanently disabled, and the separate Radeon graphics chip has 28 active compute units across 32 positions.

The question started with the original Steam Deck. Its custom processor was suspected of sharing a design with AMD silicon used in the Magic Leap 2 headset. That raised a possibility: could a processor designed for one product carry an unused vision accelerator into another? That possibility prompted this read-only investigation of one Valve Steam Machine, code-named **Fremont**.

[Short report](reports/summary.md) · [Detailed findings](findings.md) · [Full capability matrix](reports/capability-matrix.md)

## What’s inside, and what appears to be switched off?

Fremont has two separate AMD chips. The **CPU** runs general-purpose code. Its identification code maps to AMD’s *Hawkpoint2* family. The closest commercial comparison is the Ryzen 5 8540U, which has integrated graphics and no supported neural processing unit. A family match leaves room for differences in Valve’s custom chip. The **discrete GPU** is the separate Navi 33 Radeon that renders graphics. [CPU identification](evidence/cpu.md) · [GPU identification](evidence/gpu.md)

| Part | Evidence from this machine |
|---|---|
| Integrated GPU (graphics inside the CPU chip) | **Strong evidence it is fused off.** Launch reporting describes it that way. Linux sees a placeholder at the expected address. The placeholder confirms that integrated graphics are unavailable. A direct fuse reading would be needed to verify the cause on this unit. [Engineering visit](https://gamersnexus.net/news-pre-built-pc/valve-steam-machine-desktop-steamos-steam-frame-vr-controller-ft-engineering) |
| Four compute-unit positions on the separate Radeon | **Confirmed inactive.** Compute units are groups of processors that do the GPU’s work. The driver counts 28 active across 32 positions. The count alone cannot establish whether the other four contain working circuits or why they are unavailable. [GPU evidence](evidence/gpu.md) |
| Neural processing unit (NPU) | **Physical presence unknown.** An NPU runs calculations used in machine learning. XDNA is AMD’s accelerator architecture. Fremont’s firmware calls the expected device an IPU and gives it address `08:00.1`. Linux finds nothing there, even though it has a driver for a related XDNA device. [NPU evidence](evidence/npu.md) |
| Audio coprocessor (ACP) | **A secondary lead.** Firmware describes this audio processor, its interfaces, and instructions to power it on and off. Linux finds no device at its expected address. Firmware shared across several products could account for those descriptions. [Firmware evidence](evidence/acpi.md) |

**What does “fused off” mean?** A chipmaker can program a one-time setting inside a chip that permanently disables a feature. Its circuits can still occupy space on the chip. This can let a manufacturer use a chip with a faulty section or sell a version with fewer features. A driver update generally cannot reverse it. Seeing an empty device address is insufficient to diagnose a fuse: the same observation could come from firmware configuration or from hardware that was never present.

**How can the BIOS name a device that Linux can’t find?** At startup, the BIOS gives Linux a set of tables called ACPI. One entry says where the IPU would appear on the computer’s internal device bus. Linux also builds an inventory of the devices it actually finds on that bus. On this machine the address appears in the first list, and the second list has no device at that address. Installing an AI driver alone would leave it with nothing to talk to.

**What did the investigation uncover?** The report documents the exact IPU address and the audio coprocessor’s power methods in this machine’s firmware. The IPU entry contains just its address. There is no confirmed discovery of a dormant accelerator or a demonstrated way to enable one. This report makes no claim to being the first to suggest those possibilities. Comparing these tables with a Ryzen 5 8540U machine could show whether AMD routinely includes that entry on products without a supported NPU. To answer the separate physical question, the best evidence would be a diagram of the silicon tied to Valve’s exact processor, or confirmation from AMD or Valve. [ACPI analysis](evidence/acpi.md) · [Outstanding questions](findings.md)

## What if the NPU were there and Linux could use it?

The Steam Machine can already run local language models on its existing processors. The possibility worth exploring is whether it could **do two things well at once**: keep a small model responsive while the Radeon is busy, within a power or frame-time limit the machine otherwise misses. Speech, vision, and text search are possible workloads. An NPU would still need compatible software for the particular model. The available evidence gives no reason to expect it to let Fremont run a larger language model, generate text faster, or improve upscaling or frame generation. For those last two, even the time spent moving image data between chips would count against the deadline for the next frame.

## Are there benchmarks?

A public **Geekbench 6.7.1 CPU** run on a Fremont with the same CPU identification scored **2,567 single-core and 8,580 multi-core**. I couldn’t verify a Geekbench result that ran on a Fremont NPU. When checking a Geekbench AI result, look for the *backend*: that field tells you which processor performed the work. [Fremont CPU score](https://browser.geekbench.com/v6/cpu/19475313) · [Example AI result using the CPU backend](https://browser.geekbench.com/ai/v1/564074)

For comparison, an independent Linux project tested a **working first-generation XDNA NPU** on a Ryzen 7 8845HS laptop. One accelerator core completed a 512-by-512 integer matrix multiplication in an average of **3.96 milliseconds**. That measures one calculation on a different chip. The language-model speeds in the same report came from the CPU and Radeon. A test of the proposed offload would measure the same model’s response time and energy use while the GPU is busy. [Benchmark setup and results](https://github.com/Scottcjn/open-xdna/blob/main/RESULTS.md)

## Follow the evidence

| Question | Evidence |
|---|---|
| Which CPU identifiers narrow down the silicon family? | [CPUID, topology and AMD revision mapping](evidence/cpu.md) |
| What did Linux find at the expected NPU address? | [PCI enumeration and XDNA driver matching](evidence/npu.md) |
| What exactly does the BIOS say about the IPU, integrated graphics and audio DSP? | [Live ACPI tables](evidence/acpi.md) and [firmware image analysis](evidence/firmware.md) |
| How does the driver report the four unavailable GPU compute-unit positions? | [Discrete GPU topology, memory and multimedia engines](evidence/gpu.md) |
| Where can I check the comparisons? | [Upstream source register](evidence/upstream-references.md) |

## Scope and reproduction

These observations come from one Valve Fremont board, revision 9, running BIOS F7F0108 and SteamOS 3.9.6. The investigation used read-only enumeration, static firmware analysis and published hardware references. No attempt was made to activate a disabled block.

The [collection scripts](scripts/) accompany the analysis. Run the shell collectors individually as the ordinary login user. collect-system.sh prints a filtered DMI, PCI, kernel configuration and driver inventory. See each script for its input and output. Keep output under raw/ with umask 077. Raw data and disassembly are ignored by git. Do not commit hardware dumps or unfiltered journals. No hardware changes are required.

Confidence terminology: CONFIRMED means directly observed, STRONG EVIDENCE means convergent observations, POSSIBLE indicates a plausible interpretation, UNKNOWN indicates insufficient evidence, and DISPROVEN indicates a contradiction. Negative results apply to this boot and the visible interfaces.
