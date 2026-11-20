# Does Fremont’s ACPI IPU declaration identify dormant XDNA?

**STRONG EVIDENCE** that the declaration is a shared platform description. A Framework Laptop 16 with an enumerated XDNA function has the **same 13 AML bytes** as Fremont. Two other vendors ship a function-1 declaration at the same bridge address in firmware for Ryzen 5 8540U or PRO 8540U products. A version-matched Lenovo boot shows just the dummy function on that bridge. **UNKNOWN** whether Fremont's silicon physically contains an XDNA array or what selected the visible PCI configuration. These comparisons remove the need to postulate a dormant NPU to explain the firmware. [Fremont boot tables](acpi.md) · [AMD’s 8040 support matrix](https://www.amd.com/content/dam/amd/en/documents/partner-hub/ryzen/amd-ryzen-8040-series-quick-reference-guide.pdf)

## The observed systems

`GP17` and `GP18` refer to the AMD platforms’ ACPI names for root-bus devices `00:08.1` and `00:08.2`. A child `_ADR` of `1` selects device 0, function 1 on the bridge’s secondary bus. Firmware can describe a PCI location before the OS enumerates it. Bus numbers depend on the individual boot. [Linux ACPI enumeration](https://docs.kernel.org/firmware-guide/acpi/enumeration.html)

| System and source | GP18 and downstream PCI | CPU graphics and ACP |
|---|---|---|
| **Fremont**, F7F0108, live namespace and saved AML | `GP18.IPU_`, `_ADR=1`. Bus `08` has only `08:00.0 1022:14ec`, class `130000`. No `.1` or accelerator node. | `GP17.VGA_` has `07:00.0 1002:145a`, class `130000`. `GP17.ACP_` describes `.5`, which is empty. Other functions on `07` do enumerate. [ACPI](acpi.md) · [PCI and driver evidence](npu.md) |
| **Dell Inspiron 14 5445, Ryzen 5 8540U**, captured processor and board, plus a later family firmware image | Dell BIOS 1.19.1 includes `GP18.NPU_`, `_ADR=1`. Retail 8540U CPU-Z record for Dell `0785MR` used BIOS 1.4.0. No matched running PCI inventory or AML from that owner was obtained. Dell documents that the Ryzen 5 configuration lacks an NPU and the Ryzen 7 configuration supports it. | CPU-Z reports Radeon 740M. The later template has `GP17.VGA_` at `.0` and `GP17.ACP_` at `.5`. [Retail capture](https://valid.x86.fr/pexzyf) · [Dell product](https://www.dell.com/en-uk/shop/laptops-2-in-1-pcs/inspiron-14-laptop/spd/inspiron-14-5445-amd-laptop) · [Dell KB 000340369](https://www.dell.com/support/kbdoc/en-us/000340369/no-npu-on-certain-dell-laptops-with-an-amd-cpu) |
| **HP EliteBook 835 G11, Ryzen 5 8540U**, Canonical certification `202401-33466` | The public configuration lists selected devices. It supplies neither GP18 AML nor a complete PCI bus inventory. | Actual iGPU `1002:1901`, subsystem `103c:8d04`, labeled Phoenix4. A separate non-PRO 8540U owner’s Linux report shows `03:00.5 1022:15e2`, class `0480`, bound to `snd_pci_ps`. [Canonical certification](https://ubuntu.com/certified/202401-33466) · [Owner’s Linux device report](https://forums.linuxmint.com/viewtopic.php?p=2785774) |
| **Lenovo ThinkPad T14 Gen 5, Ryzen 5 PRO 8540U**, two owner captures | BIOS 1.05 (`R2LET24W`) shows `00:08.2 → c5:00.0 1022:14ec` alone. BIOS 1.07 (`R2LET26W`) on the second laptop gives `c4:00.0 1022:14ec` alone. Both logs associate the parent with `GP18`. The matching 1.05 firmware contains `GP18.NPU_` with `_ADR=1`. | Both show `GP17.VGA_` = `1002:1901` and `GP17.ACP_` = `1022:15e2`. The 1.05 boot registers `GP17.ACP_.PWRS`. The owner separately posted unfiltered `lspci -nn`. [1.05 topology and DSDT header](https://gist.github.com/RocketRene/40694400550cf4c719b02e6f6239c680/5dc4292d693dc1033e8d4dabe09858c3644b5600) · [1.07 topology](https://gist.github.com/RocketRene/8f0a32112f486958af9dc28f7fab5ac5/8f947c40d59baf2981cf76615bdabf81f640e748) · [PCI listing](https://gist.github.com/RocketRene/b80875a1c35a894572101c1b73497e56/956df5e036eaa81487ef3ea521c33e47e8e7474a) |
| **Framework Laptop 16, Ryzen 9 7940HS**, BIOS 03.03, matching Linux Hardware Database DMI, ACPI and PCI records | `GP18.IPU_`, `_ADR=1`. `00:08.2 → c6`, `c6:00.0 1022:14ec` **and** `c6:00.1 1022:1502`, class `1180`, with PCI memory regions 0, 1, 2 and 4. Fedora’s 6.8.7 listing supplies enumeration evidence. | `c5:00.0 1002:15bf` binds `amdgpu`, `c5:00.5 1022:15e2` binds `snd_pci_ps`. [DMI blob](https://api.github.com/repos/linuxhw/DMI/git/blobs/65f9bddc131baee180fff93d8e817e2f81a50d31) · [ACPI disassembly blob](https://api.github.com/repos/linuxhw/ACPI/git/blobs/cba1ea18433903a6685c1452c0c5e4077554f0c3) · [PCI blob](https://api.github.com/repos/linuxhw/LsPCI/git/blobs/fa27066bf98415b367b6e613917e678d682f97a5) |

**CONFIRMED** on the reported processor signatures. A separate 8540U Inspiron 14 5445 benchmark records family 25, model 124, stepping 0, six cores and 12 threads. This agrees with Fremont’s `CPUID.1:EAX=00a70fc0`; AMD assigns the signature to Hawkpoint2. It makes the non-PRO CPU a meaningful comparator. The signature alone does not identify an individual mask, ordering code, package wiring or fuse map. [Dell processor capture](https://browser.geekbench.com/v6/cpu/5601227) · [Fremont CPUID and AMD's signature source](cpu.md)

## What the firmware actually encodes

Offsets below are hexadecimal and relative to the start of the DSDT. The interval begins at the extended `DeviceOp`. Each child body contains one `Name(_ADR, …)` and ends at the indicated boundary. There is no child `_STA`, `_CRS`, `_INI`, `_PS0` or `_PS3` in these bodies. The parent supplies PCI routing. Other firmware and separately installed SSDTs can augment a device.

| Source of DSDT | Accelerator child byte interval, end exclusive | Child AML bytes |
|---|---|---|
| Fremont live, 18,721 bytes, SHA-256 `1a6b537da48f21a62ad52b375272315f45541239b7b4c6c58d2f4d36f225db7e` | `0x1bb5..0x1bc2` | `5b 82 0b 49 50 55 5f 08 5f 41 44 52 01` (`IPU_`, One) |
| Framework live, 39,646 bytes, SHA-256 `d1b635878eed5fe583de8abee78a133cd07d634a0d40a9c2b6c91f0814eb1d7d` | `0x47c1..0x47ce` | `5b 82 0b 49 50 55 5f 08 5f 41 44 52 01` (`IPU_`, One) |
| Dell BIOS 1.19.1 template, 74,784 bytes, SHA-256 `278789393bc4468591ecf41cf5b6754b3dee03c362e3e938fe38cb7124e7180e` | `0x47d6..0x47e3`, GP18 starts `0x4700` | `5b 82 0b 4e 50 55 5f 08 5f 41 44 52 01` (`NPU_`, One) |
| Lenovo BIOS 1.05 template, 99,768 bytes, SHA-256 `cadec55815a40e913023607badbacd32d61c3fcd36551d2cfb58feb8f2426a69` | `0x443e..0x444c`, GP18 starts `0x4368` | `5b 82 0c 4e 50 55 5f 08 5f 41 44 52 0a 01` (`NPU_`, ByteConst 1) |

**CONFIRMED** cross-platform reuse extends to power-management descriptions. The Framework DSDT has `GP17.ACP_` at function 5. Lines 40104–40116 of its archived table disassembly give the same `_PS0` and `_PS3` sequence as Fremont `SSDT27.dsl` lines 418–430, including the diagnostic `M460` and calls `M276(Zero)` / `M277(Zero)`. Framework has a bound ACP. Fremont leaves that function empty. The same methods can exist in either configuration. The Framework listings also reference `GP18.IPU` as a package string (line 31423), as Fremont does in `SSDT17.dsl` line 430. No IPU-specific memory range or additional named IPU power/status method appeared in the Framework listings. [Framework ASL blob](https://api.github.com/repos/linuxhw/ACPI/git/blobs/cba1ea18433903a6685c1452c0c5e4077554f0c3) · [Fremont AML evidence](acpi.md)

**STRONG EVIDENCE** for the Lenovo comparison. The public 1.05 boot identifies OEM `LENOVO`, table `AMD_EDK2`, revision 0, compiler `INTL 20180313`, length `0x185b8`. The same release's template matches every one of those fields except OEM ID (`AMD   `). Its `UPEP` SSDT template even includes the text path `\_SB.PCI0.GP18.NPU`. Dell’s `UPEP` template contains the same path twice. The version match ties the Lenovo image to a real negative PCI capture. A live Lenovo DSDT body is still needed to establish the exact AML installed on that boot. For the **non-PRO** 8540U, the exact Dell board and Canonical PCI examples establish CPU and graphics product identity, while the shared Dell image establishes available firmware content. The later HP sample below supplies a complete PCI tree on one non-PRO boot. Its DSDT/SSDT bodies remain unavailable. [Lenovo release notes](https://download.lenovo.com/pccbbs/mobiles/r2luj24w.txt) · [Dell BIOS release](https://www.dell.com/support/home/en-my/drivers/driversdetails?driverid=5833K)

## Working XDNA control and verdict

**STRONG EVIDENCE** of a working first-generation XDNA stack comes from a separate HP Victus 16 with a Ryzen 7 8845HS. Its operator publishes PCI `1022:1502`, XRT discovery at `06:00.1` as `RyzenAI-npu1`, firmware `1.5.5.391`, a passed 4,096-byte passthrough and a 512³ int16 matrix multiply checked against NumPy. This is an operator-reported workload. It was not rerun on either Valve system or attributed to the Framework capture. Upstream Linux v6.14 matches AMD `1502` via its PCI driver, then selects `dev_npu1_info` for revision `00`. [Pinned HP workload results](https://github.com/Scottcjn/open-xdna/blob/6c8c680a904c781a5dd0d78886d11c847a286fa6/RESULTS.md) · [Linux PCI and revision tables](https://github.com/torvalds/linux/blob/38fec10eb60d687e30c8c6b5420d86e8149f7557/drivers/accel/amdxdna/amdxdna_pci_drv.c#L34-L47)

**DISPROVEN for this boot** that a supported XDNA PCI function on Fremont is simply waiting for a driver. **CONFIRMED** that both device layouts, with and without a visible `1502`, coexist with closely matching firmware declarations. The exact non-PRO 8540U has no supported Ryzen AI according to AMD. **UNKNOWN** whether XDNA transistors are absent, permanently disabled, or hidden on Fremont. The iGPU placeholder and ACP methods likewise do not measure individual fuses. A binding graphics or audio endpoint on a comparator supplies a positive PCI control for those two classes. [AMD product comparison](https://www.amd.com/content/dam/amd/en/documents/partner-hub/ryzen/amd-ryzen-8040-series-quick-reference-guide.pdf) · [Local iGPU evidence and first-hand engineering reporting](cpu.md)

## Reproduce the template comparison offline

The inputs are Dell `FOLDER14389948M/1/BIOS_IMG.rcv` (34,850,392 bytes, driver ID `5833K`) and Lenovo `r2luj24w.exe` (41,634,856 bytes, release `R2LET24W`). The following reads them only as data and prints each table digest and the entire child declaration. Run it in a private directory containing those two downloads. It uses only Python’s standard library. [Dell recovery image](https://downloads.dell.com/FOLDER14389948M/1/BIOS_IMG.rcv) · [Lenovo update image](https://download.lenovo.com/pccbbs/mobiles/r2luj24w.exe)

```python
from hashlib import sha256
from lzma import FILTER_LZMA2, FORMAT_ALONE, FORMAT_RAW, LZMADecompressor
from pathlib import Path

def verified_file(name, digest):
    data = Path(name).read_bytes()
    assert sha256(data).hexdigest() == digest
    return data

def check_dsdt(stream, offset, child, size):
    decoder = LZMADecompressor(format=FORMAT_ALONE, memlimit=64 << 20)
    volume = decoder.decompress(stream, max_length=32 << 20)
    assert decoder.eof
    length = int.from_bytes(volume[offset + 4:offset + 8], 'little')
    table = volume[offset:offset + length]
    assert table[:4] == b'DSDT' and len(table) == length and sum(table) % 256 == 0
    print(length, sha256(table).hexdigest(), table[child:child + size].hex(' '))

dell = verified_file('BIOS_IMG.rcv', 'f19192a5fc10416efab7c67500a69bb5eb9c472e6c2a6b8dec7895ce146ea729')
check_dsdt(dell[0x18c0860:0x1ccd904], 0xe88ca0, 0x47d6, 13)

lenovo = verified_file('r2luj24w.exe', 'f9338a158e76511b4ff50468d61a040f242c41fcdefc4d11a48a67b438972b06')
assert lenovo[0x2c000:0x2c005] == b'zlb\x1a\x1a'
decoder = LZMADecompressor(format=FORMAT_RAW, filters=[{'id': FILTER_LZMA2, 'dict_size': 32 << 20}])
prefix = decoder.decompress(lenovo[0x2c005:], max_length=0x4dbdc0a)
check_dsdt(prefix[0x48f1b41:0x4dbdc0a], 0x2ddf20, 0x443e, 14)
```

For the Framework comparison, `linuxhw/ACPI` commit `d6d30c6ef6f45506567f25a302c64f009d8f5f4e` contains both the ASL listing and an `acpidump`-style hex file under `Notebook/Framework/Laptop/Laptop 16/`. In the latter, decode the DSDT hex column to recover the digest in the table. Compare the same public system entry in `linuxhw/DMI` at `57b21bc6fdd863380e99c228c22aafcd1509528c` and `linuxhw/LsPCI` at `716d5be960ffcac591ebb3309361bdce17cf6079`. The PCI text SHA-256 is `b5823c065047d37762a8fce024a5d401cc2b33875c96aa02407de9622a432694`. [Hex dump blob](https://api.github.com/repos/linuxhw/ACPI/git/blobs/a76f72e0203e32f742e67cbcfac03009c514857c) · [PCI blob](https://api.github.com/repos/linuxhw/LsPCI/git/blobs/fa27066bf98415b367b6e613917e678d682f97a5)

## Exact non-PRO 8540U boot with PCI and ACPI observations

**CONFIRMED.** HP OmniBook 5 Laptop 16-bc1xxx probe `3930a3484f` (2026-09-30 UTC, CachyOS kernel `7.2.8-1-cachyos`, BIOS F.05) closes the earlier gap in the complete PCI comparison. Its own boot log names the Ryzen 5 **8540U**, family `19h`, model `7ch`, stepping 0 (line 331). The verbose PCI listing has 35 functions. Bridge `00:08.2 1022:14eb` has secondary and subordinate bus `04` (lines 271–279). The only function on that bus is `04:00.0 1022:14ec` (line 981). There is no `04:00.1` or `1022:1502` anywhere in the listing. Fremont exhibits the same downstream layout on bus `08`. [Probe](https://linux-hardware.org/?probe=3930a3484f) · [Full PCI log](https://linux-hardware.org/?probe=3930a3484f&log=lspci_all)

The same boot loaded 34 AML tables, including a DSDT with OEM/table ID `HPQOEM/SLIC-MPC` and length `0xcef9` (kernel log lines 65 and 402). Linux registered `\_SB_.PCI0.GP17.VGA_.PWRS` and `\_SB_.PCI0.GP17.ACP_.PWRS` (421–422). On this 8540U, `03:00.0 1002:1901` binds `amdgpu` and `03:00.5 1022:15e2` binds `snd_pci_ps`. The probe’s public log menu provides neither AML bytes nor a complete ACPI namespace. **UNKNOWN** whether this boot installed an address-only IPU/NPU child under GP18 or what methods it contained. [Boot log](https://linux-hardware.org/?probe=3930a3484f&log=dmesg) · [PCI driver bindings](https://linux-hardware.org/?probe=3930a3484f&log=lspci_all)

To verify the evidence hashes, hash the UTF-8 text content of the log page’s `div.code` (HTML entities decoded, markup omitted, no added final newline). SHA-256 is `57b810800cba399a796e95c226f89c388ee5c77661ca2b58873230d25cd22d06` for `dmesg` and `34ee35a0c9c7392c6e8be15a4dbb2a11aae3be8602eb296708bf72018c6151f7` for `lspci_all`. Both pages carry the same probe ID and collection timestamp.
