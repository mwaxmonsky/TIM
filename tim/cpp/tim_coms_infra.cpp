/**
 * @file tim_coms_infra.cpp
 * @brief Implementation of the TIM checksum service.
 */

// #include <bit>

#include <AMReX_Gpu.H>
#include <AMReX_ParallelDescriptor.H>
#include <AMReX_Reduce.H>

#include "tim_coms_infra.hpp"

namespace TIM {

amrex::Long checksum(amrex::Box const& bx, amrex::Array4<amrex::Real> const& arr,
                     std::optional<amrex::Real> mask)
{
    // Cast needed due to lack of C++20 support in icpc needed to do:
    //   auto checksum = std::bit_cast<int64_t>(var);
    // See https://en.wikipedia.org/wiki/Fast_inverse_square_root#Overview_of_the_code
    // for logic behind casting.
    // Also need C++20 to use std::view::filter for mask.
    amrex::Reducer<amrex::ReduceOpSum, amrex::Long> reducer;
    using Result_t = typename decltype(reducer)::Result_t;

    if (mask) {
        amrex::Long mask_bytes;
        std::memcpy(&mask_bytes, &(*mask), sizeof(mask_bytes));

        reducer.eval(bx,
            [=] AMREX_GPU_DEVICE (int i, int j, int k) -> Result_t
            {
                amrex::Long bits;
                std::memcpy(&bits, &arr(i,j,k), sizeof(bits));
                return { (bits == mask_bytes) ? 0 : bits };
            });
    } else {
        reducer.eval(bx,
            [=] AMREX_GPU_DEVICE (int i, int j, int k) -> Result_t
            {
                amrex::Long bits;
                std::memcpy(&bits, &arr(i,j,k), sizeof(bits));
                return bits;
            });
    }
    amrex::Long checksum = amrex::get<0>(reducer.getResult());
    amrex::ParallelDescriptor::ReduceLongSum(checksum);
    return checksum;
}

} // namespace TIM
