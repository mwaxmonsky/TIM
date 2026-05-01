#!/bin/bash
# Usage: ./build.sh [options]
#
# Builds TIM using CMake. Assumes dependencies (MPI, NetCDF, AMReX) are
# already on CMAKE_PREFIX_PATH (e.g. via an active Spack environment).
#
# Required environment variables:
#   TIM_ROOT    Path to the TIM repository clone
#
# Options:
#   --debug         Full clean rebuild (--fresh + --clean-first)
#   --build-dir DIR Override build directory (default: $TIM_ROOT/build)

set -e

if [[ -z "${TIM_ROOT:-}" ]]; then
    echo "Error: TIM_ROOT is not set." >&2
    exit 1
fi

# Defaults
build_dir="$TIM_ROOT/build"
debug=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --debug)        debug=true; shift ;;
        --build-dir)    build_dir="$2"; shift 2 ;;
        *)              break ;;
    esac
done

# Configure
cmake_configure_opts=(
    -G Ninja
    -S "$TIM_ROOT"
    -B "$build_dir"
    -D64BIT=ON
    -D32BIT=OFF
)
if [[ "$debug" == true ]]; then
    cmake_configure_opts+=(-DCMAKE_BUILD_TYPE=Debug --fresh)
fi
cmake "${cmake_configure_opts[@]}"

# Build
cmake_build_opts=()
if [[ "$debug" == true ]]; then
    cmake_build_opts+=(--clean-first)
fi
cmake --build "$build_dir" "${cmake_build_opts[@]}"
