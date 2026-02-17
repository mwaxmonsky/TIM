#include <iostream>
#include <cstdint>
// #include <bit>

#include <AMReX_Gpu.H>
#include <AMReX_ParallelDescriptor.H>
#include <AMReX_Reduce.H>

#include "tim_coms_infra_C_API.h"
#include "tim_coms_infra.hpp"

namespace TIM {

int64_t checksum(double* field, size_t field_size, double* mask_val)
{
    // Cast needed due to lack of C++20 support in icpc needed to do:
    //   auto checksum = std::bit_cast<int64_t>(var);
    // See https://en.wikipedia.org/wiki/Fast_inverse_square_root#Overview_of_the_code
    // for logic behind casting.
    // Also need C++20 to use std::view::filter for mask.
    amrex::Long checksum = 0;
    if(mask_val)
        checksum = amrex::Reduce::Sum<amrex::Long>(field_size, 
            [=] AMREX_GPU_DEVICE (size_t i) -> amrex::Long {
                return (field[i] == (*mask_val)) ? 0 : (* ( amrex::Long * ) &field[i]);
            });
    else
        checksum = amrex::Reduce::Sum<amrex::Long>(field_size, 
            [=] AMREX_GPU_DEVICE (size_t i) -> amrex::Long {
                return * ( amrex::Long * ) &field[i];
            });
    amrex::ParallelDescriptor::ReduceLongSum(checksum);
    return checksum;
}

} // namespace TIM

int64_t c_tim_chksum_r8_1d(double* field, size_t field_size, double* mask_val) {
    return TIM::checksum(field, field_size, mask_val);
}
