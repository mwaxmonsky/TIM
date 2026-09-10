module tim_coms_infra_interface

use iso_fortran_env, only : int32, int64
use iso_c_binding,   only : c_int64_t, c_double, c_size_t, c_ptr, c_null_ptr, c_loc
use array_mod, only : RealArray_c
use box_mod,   only : Box_c
implicit none
private

public :: tim_chksum

interface tim_chksum_c
  function tim_chksum_c(field_ptr, field_size, mask_ptr, pelist_loc, pelist_size) bind(c, name="tim_chksum_c")
    import c_ptr, c_int64_t, c_size_t
    integer(c_int64_t)                        :: tim_chksum_c
    type(Box_C),            value, intent(in) :: box
    type(RealArray_C),      value, intent(in) :: field
    type(c_ptr),            value, intent(in) :: mask_ptr
    type(c_ptr),            value, intent(in) :: pelist_loc
    integer(c_size_t),      value, intent(in) :: pelist_size
  end function tim_chksum_c
end interface tim_chksum_c

interface tim_chksum
  module procedure tim_chksum_real_0d
  module procedure tim_chksum_real_1d
  module procedure tim_chksum_real_2d
  module procedure tim_chksum_real_3d
  module procedure tim_chksum_real_4d
end interface tim_chksum

contains

function tim_chksum_real_0d(field, pelist, mask_val) result(chksum)
  real,              target, intent(in) :: field               !< Input scalar
  integer, optional, target, intent(in) :: pelist(:)           !< PE list of ranks to checksum
  real,    optional, target, intent(in) :: mask_val            !< FMS mask value
  type(RealArray_C)                     :: field_in
  type(Box_C)                           :: box
  type(c_ptr)                           :: pelist_loc, mask_loc !< c pointers to field and mask
  integer(c_size_t)                     :: pelist_size
  integer(kind=int64)                   :: chksum              !< checksum of array

  call field_in%alloc(lb=[1], ub=[1], source=[field])
  call box%safe_alloc(ndims=1)
  call box%set(idxS=[1], idxE=[1])

  if(present(mask_val)) then
    mask_loc = c_loc(mask_val)
  else
    mask_loc = c_null_ptr
  end if

  if (present(pelist)) then
    pelist_loc  = c_loc(pelist, kind=c_size_t)
    pelist_size = size(pelist)
  else
    pelist_loc  = c_null_ptr
    pelist_size = 0
  end if

  chksum = tim_chksum_c(box, field_in, mask_loc, pelist_loc, pelist_size)

  field_in%free()
end function tim_chksum_real_0d

function tim_chksum_real_1d(field, pelist, mask_val) result(chksum)
  real, dimension(:), target, intent(in) :: field               !< Input array
  integer,  optional, target, intent(in) :: pelist(:)           !< PE list of ranks to checksum
  real,     optional, target, intent(in) :: mask_val            !< FMS mask value
  type(RealArray_C)                      :: field_in
  type(Box_C)                            :: box
  type(c_ptr)                            :: pelist_loc, mask_loc !< c pointers to field and mask
  integer(c_size_t)                      :: pelist_size
  integer(kind=int64)                    :: chksum              !< checksum of array

  call field_in%alloc(lb=LBOUND(field), ub=UBOUND(field), source=field)
  call box%safe_alloc(ndims=1)
  call box%set(idxS=[1],idxE=[size(field, 1)])

  if(present(mask_val)) then
    mask_loc = c_loc(mask_val)
  else
    mask_loc = c_null_ptr
  end if

  if (present(pelist)) then
    pelist_loc  = c_loc(pelist, kind=c_size_t)
    pelist_size = size(pelist)
  else
    pelist_loc  = c_null_ptr
    pelist_size = 0
  end if

  chksum = tim_chksum_c(box, field_in, mask_loc, pelist_loc, pelist_size)

  field_in%free()
end function tim_chksum_real_1d

function tim_chksum_real_2d(field, pelist, mask_val) result(chksum)
  real, dimension(:,:), target, intent(in) :: field               !< Unrotated input field
  integer,    optional, target, intent(in) :: pelist(:)           !< PE list of ranks to checksum
  real,       optional, target, intent(in) :: mask_val            !< FMS mask value
  type(RealArray_C)                        :: field_in
  type(Box_C)                              :: box
  type(c_ptr)                              :: pelist_loc, mask_loc !< c pointers to field and mask
  integer(c_size_t)                        :: pelist_size
  integer(kind=int64)                      :: chksum              !< checksum of array

  call field_in%alloc(lb=LBOUND(field), ub=UBOUND(field), source=field)
  call box%safe_alloc(ndims=2)
  call box%set(idxS=[1,1],idxE=[size(field, 1), &
                                size(field, 2)])

  if(present(mask_val)) then
    mask_loc = c_loc(mask_val)
  else
    mask_loc = c_null_ptr
  end if

  if (present(pelist)) then
    pelist_loc  = c_loc(pelist, kind=c_size_t)
    pelist_size = size(pelist)
  else
    pelist_loc  = c_null_ptr
    pelist_size = 0
  end if

  chksum = tim_chksum_c(box, field_in, mask_loc, pelist_loc, pelist_size)

  field_in%free()
end function tim_chksum_real_2d

function tim_chksum_real_3d(field, pelist, mask_val) result(chksum)
  real, dimension(:,:,:), target, intent(in) :: field               !< Unrotated input field
  integer,      optional, target, intent(in) :: pelist(:)           !< PE list of ranks to checksum
  real,         optional, target, intent(in) :: mask_val            !< FMS mask value
  type(RealArray_C)                          :: field_in
  type(Box_C)                                :: box
  type(c_ptr)                                :: pelist_loc, mask_loc !< c pointers to field and mask
  integer(c_size_t)                          :: pelist_size
  integer(kind=int64)                        :: chksum              !< checksum of array

  call field_in%alloc(lb=LBOUND(field), ub=UBOUND(field), source=field)
  call box%safe_alloc(ndims=3)
  call box%set(idxS=[1,1,1],idxE=[size(field, 1), &
                                  size(field, 2), &
                                  size(field, 3)])

  if(present(mask_val)) then
    mask_loc = c_loc(mask_val)
  else
    mask_loc = c_null_ptr
  end if

  if (present(pelist)) then
    pelist_loc  = c_loc(pelist, kind=c_size_t)
    pelist_size = size(pelist)
  else
    pelist_loc  = c_null_ptr
    pelist_size = 0
  end if

  chksum = tim_chksum_c(box, field_in, mask_loc, pelist_loc, pelist_size)

  field_in%free()
end function tim_chksum_real_3d

function tim_chksum_real_4d(field, pelist, mask_val) result(chksum)
  real, dimension(:,:,:,:), target, intent(in) :: field               !< Unrotated input field
  integer,        optional, target, intent(in) :: pelist(:)           !< PE list of ranks to checksum
  real,           optional, target, intent(in) :: mask_val            !< FMS mask value
  type(RealArray_C)                            :: field_in
  type(Box_C)                                  :: box
  type(c_ptr)                                  :: pelist_loc, mask_loc !< c pointers to field and mask
  integer(c_size_t)                            :: pelist_size
  integer(kind=int64)                          :: chksum              !< checksum of array

  call field_in%alloc(lb=LBOUND(field), ub=UBOUND(field), source=field)
  call box%safe_alloc(ndims=4)
  call box%set(idxS=[1,1,1,1],idxE=[size(field, 1), &
                                    size(field, 2), &
                                    size(field, 3), &
                                    size(field, 4)])
  
  if(present(mask_val)) then
    mask_loc = c_loc(mask_val)
  else
    mask_loc = c_null_ptr
  end if

  if (present(pelist)) then
    pelist_loc  = c_loc(pelist, kind=c_size_t)
    pelist_size = size(pelist)
  else
    pelist_loc  = c_null_ptr
    pelist_size = 0
  end if

  chksum = tim_chksum_c(box, field_in, mask_loc, pelist_loc, pelist_size)

  field_in%free()
end function tim_chksum_real_4d

end module tim_coms_infra_interface

