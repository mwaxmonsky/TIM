#include <iostream>
#include <cstdint>

#include <AMReX_Gpu.H>
#include <AMReX_ParallelDescriptor.H>
#include <AMReX_Reduce.H>
// #include <bit>

extern "C" int64_t tim_chksum_r8_1d(double* field, size_t field_size, double* mask_val)
{
    // Cast needed due to lack of C++20 support in icpc needed to do:
    //   auto checksum = std::bit_cast<int64_t>(var);
    // See https://en.wikipedia.org/wiki/Fast_inverse_square_root#Overview_of_the_code
    // for logic behind casting.
    amrex::Long checksum = amrex::Reduce::Sum<amrex::Long>(field_size, 
        [=] AMREX_GPU_DEVICE (int i) -> amrex::Long {
            return * ( amrex::Long * ) &field[i];
        });
    amrex::ParallelDescriptor::ReduceLongSum(checksum);
    return checksum;
}

