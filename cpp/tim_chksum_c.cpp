#include <iostream>
#include <cstdint>
#include <AMReX_ParallelDescriptor.H>
// #include <bit>

extern "C" int64_t tim_chksum_r8_1d(double* field, size_t field_size, double* mask_val)
{
    int64_t checksum = 0;

    // Cast needed due to lack of C++20 support in icpc needed to do:
    //   auto checksum = std::bit_cast<int64_t>(var);
    // See https://en.wikipedia.org/wiki/Fast_inverse_square_root#Overview_of_the_code
    // for logic behind casting.
    for(size_t i = 0; i < field_size; ++i)
        checksum += * ( int64_t * ) &field[i];
    amrex::ParallelDescriptor::ReduceLongSum(checksum);
    return checksum;
}

