// #include <bit>

#include <AMReX_Gpu.H>
#include <AMReX_ParallelDescriptor.H>
#include <AMReX_Reduce.H>

#include "tim_coms_infra.hpp"

namespace TIM {

amrex::Long checksum(amrex::Box const& bx, amrex::Array4<amrex::Real> const& arr)
{
    // Cast needed due to lack of C++20 support in icpc needed to do:
    //   auto checksum = std::bit_cast<int64_t>(var);
    // See https://en.wikipedia.org/wiki/Fast_inverse_square_root#Overview_of_the_code
    // for logic behind casting.
    // Also need C++20 to use std::view::filter for mask.
    amrex::ReduceOps<amrex::ReduceOpSum> reduce_ops;
    amrex::ReduceData<amrex::Long> reduce_data(reduce_ops);
    using ReduceTuple = typename decltype(reduce_data)::Type;

    reduce_ops.eval(bx, reduce_data,
        [=] AMREX_GPU_DEVICE (int i, int j, int k) -> ReduceTuple
        {
            return { * ( amrex::Long * ) &arr(i, j, k) };
        });
    amrex::Long checksum = amrex::get<0>(reduce_data.value());
    amrex::ParallelDescriptor::ReduceLongSum(checksum);
    return checksum;
}

amrex::Long checksum(amrex::Box const& bx, amrex::Array4<amrex::Real> const& arr, amrex::Real mask)
{
    amrex::ReduceOps<amrex::ReduceOpSum> reduce_ops;
    amrex::ReduceData<amrex::Long> reduce_data(reduce_ops);
    using ReduceTuple = typename decltype(reduce_data)::Type;

    amrex::Long mask_bytes = * ( amrex::Long * ) &mask;

    reduce_ops.eval(bx, reduce_data,
        [=] AMREX_GPU_DEVICE (int i, int j, int k) -> ReduceTuple
        {
            amrex::Long field_checksum = * ( amrex::Long * ) &arr(i, j, k);
            return (field_checksum == mask_bytes) ? 0 : field_checksum;
        });
    amrex::Long checksum = amrex::get<0>(reduce_data.value());
    amrex::ParallelDescriptor::ReduceLongSum(checksum);
    return checksum;
}

} // namespace TIM
