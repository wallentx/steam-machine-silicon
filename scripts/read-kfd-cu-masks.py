#!/usr/bin/env python3
"""Recover gfx1102 CU masks from cached KFD topology on a single-XCC GPU."""

import argparse
from pathlib import Path


def properties(path):
    return dict(line.split(maxsplit=1) for line in path.read_text().splitlines())


def cu_masks(node):
    props = properties(node / "properties")
    if props["gfx_target_version"] != "110002" or props["num_xcc"] != "1":
        raise ValueError("expected a single-XCC gfx1102 KFD node")

    base = int(props["simd_id_base"])
    width = int(props["cu_per_simd_array"])
    array_count = int(props["array_count"])
    per_engine = int(props["simd_arrays_per_engine"])
    if min(width, array_count, per_engine) < 1 or array_count % per_engine:
        raise ValueError("invalid shader-array dimensions")
    masks = [0] * array_count
    for cache in (node / "caches").glob("*/properties"):
        info = properties(cache)
        # KFD emits L1 sibling bits relative to this cache's first active CU.
        if info["level"] != "1" or not int(info["type"]) & 8:
            continue
        first = int(info["processor_id_low"]) - base
        bits = info["sibling_map"].split(",")
        if first < 0 or first >= width * array_count or any(bit not in ("0", "1") for bit in bits):
            raise ValueError(f"invalid L1 topology at {cache}")
        for offset, bit in enumerate(bits):
            if bit == "1":
                array, cu = divmod(first + offset, width)
                if array != first // width:
                    raise ValueError(f"L1 sibling extends outside its shader array at {cache}")
                masks[array] |= 1 << cu

    active = sum(mask.bit_count() for mask in masks)
    if not active or active * int(props["simd_per_cu"]) != int(props["simd_count"]):
        raise ValueError("L1 cache coverage disagrees with the node's SIMD count")
    return width, per_engine, masks


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("node", type=Path, help="live or saved KFD topology node directory")
    args = parser.parse_args()
    try:
        width, per_engine, masks = cu_masks(args.node)
    except (OSError, KeyError, ValueError) as exc:
        parser.exit(1, f"cannot decode topology: {exc}\n")

    print("SE SA active_CU_mask inactive_CU_mask active_CUs")
    for array, mask in enumerate(masks):
        engine, local_array = divmod(array, per_engine)
        print(engine, local_array, hex(mask), hex(((1 << width) - 1) ^ mask), mask.bit_count())


if __name__ == "__main__":
    main()
