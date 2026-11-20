#include <cpuid.h>
/* Built as a small shared library so no system libc headers are required. */
void query(unsigned leaf, unsigned sub, unsigned *result) {
    __cpuid_count(leaf, sub, result[0], result[1], result[2], result[3]);
}
