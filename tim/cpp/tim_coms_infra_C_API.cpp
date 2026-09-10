/**
 * @file tim_coms_infra_C_API.cpp
 * @brief C-API translation unit of the TIM checksum service.
 */

#include "tim_coms_infra_C_API.h"
#include "tim_coms_infra.hpp"
#include "turbotmp_helper.hpp"

int64_t tim_chksum_c(const Box_C* bx_HOST, const RealArray_C* field_HOST, double* mask_val, bool global_chksum) {
    /// Define Active domain (checksum only over real cells)
    amrex::Box bx(amrex::IntVect(bx_HOST->idxS[0]-1, bx_HOST->idxS[1]-1, bx_HOST->idxS[2]-1),
                  amrex::IntVect(bx_HOST->idxE[0]-1, bx_HOST->idxE[1]-1, bx_HOST->idxE[2]-1));

    /// Create A4 container for the Fortran array
    auto field_DEV = turbotmp::make_array4(field_HOST->shape[0], field_HOST->shape[1], field_HOST->shape[2], 1);

    /// Copy from Fortran array to A4 container
    turbotmp::copy_FortranHost_to_array4(field_HOST->data, field_DEV);

    ///-------------------------------------------------
    /// Execute checksum
    ///-------------------------------------------------
    int64_t chksum = mask_val ? TIM::checksum(bx, field_DEV.arr, *mask_val)
                              : TIM::checksum(bx, field_DEV.arr);

    /// Free a4 container
    turbotmp::free_array4(field_DEV);

    return chksum;
}
