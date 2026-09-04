#pragma once
/**
 * @file tim_coms_infra.hpp
 * @brief Checksum service of the TIM communication infrastructure.
 */

#include <AMReX_Array4.H>
#include <AMReX_Box.H>

/// @brief TURBO Infrastructure for MOM (TIM) — the C++ infrastructure layer.
namespace TIM {
    /// @brief Bitwise checksum of a distributed field.
    /// @param bx        Region to compute checksum of.
    /// @param arr       Values to compute checksum of possibly
    ///                  including ghost rows and neighboring data
    /// @return The global checksum (identical on every rank).
    amrex::Long checksum(amrex::Box const& bx, amrex::Array4<amrex::Real> const& arr);
    /// @brief Bitwise checksum of a distributed field.
    /// @param bx         Region to compute checksum of.
    /// @param arr        Values to compute checksum of possibly
    ///                   including ghost rows and neighboring data
    /// @param mask       Value marking masked elements (compared bitwise);
    /// @return The global checksum (identical on every rank).
    amrex::Long checksum(amrex::Box const& bx, amrex::Array4<amrex::Real> const& arr, amrex::Real mask);
}  // namespace TIM
