#pragma once

#include <stdint.h>
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

int64_t c_tim_chksum_r8_1d(double* field, size_t field_size, double* mask_val);

#ifdef __cplusplus
}
#endif
