#!/bin/bash
# Usage: ./build.sh [options]
#
# Builds TIM using CMake. Assumes dependencies (MPI, NetCDF, AMReX) are
# already on CMAKE_PREFIX_PATH (e.g. via an active Spack environment).
#
# Optional environment variables:
#   TIM_ROOT    Path to the TIM repository clone (defaults to this script's
#               directory, so it normally need not be set)
#
# Options:
#   --debug         Full clean rebuild (deletes build dir and rebuilds from scratch)
#   --ninja         Use Ninja generator instead of the default (Unix Makefiles)
#   --build-dir DIR Override build directory (default: $TIM_ROOT/build)
#   --parallel N    Build with N parallel jobs

set -eo pipefail

TIM_ROOT="${TIM_ROOT:-$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"

# Sanity-check the deduced/overridden root really is a TIM tree
if [[ ! -f "$TIM_ROOT/CMakeLists.txt" ]]; then
    echo "Error: TIM_ROOT ('$TIM_ROOT') doesn't look like a TIM checkout." >&2
    exit 1
fi

# Defaults
build_dir="$TIM_ROOT/build"
build_type="Release"
debug=false
ninja=false
parallel_jobs=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --debug)        debug=true; shift ;;
        --ninja)        ninja=true; shift ;;
        --build-dir)    build_dir="$2"; shift 2 ;;
        --parallel)     parallel_jobs="$2"; shift 2 ;;
        *)              echo "Error: unknown argument '$1'" >&2; exit 1 ;;
    esac
done

if [[ "$debug" == true ]]; then
    build_type="Debug"
    rm -rf "$build_dir"
fi

# Configure
cmake_configure_opts=(
    -S "$TIM_ROOT"
    -B "$build_dir"
    -DCMAKE_BUILD_TYPE="$build_type"
)
[[ "$ninja" == true ]] && cmake_configure_opts+=(-G Ninja)
cmake "${cmake_configure_opts[@]}"

# Build
cmake_build_opts=("$build_dir")
[[ -n "$parallel_jobs" ]] && cmake_build_opts+=(--parallel "$parallel_jobs")
cmake --build "${cmake_build_opts[@]}"
