#!/usr/bin/env bash

# Usage:
#  build-${PY_LIB}-python-wheel [OPTION]...
#
# Build a ${PY_LIB} wheel.
#
# @_include_value_options rapids-get-num-archs-jobs-and-load -h;
# @_include_cmake_options;
# CMake Install Options:
#  --strip  Strip before installing.
#
# @_include_pip_wheel_options;
# @_include_pip_package_index_options;
# @_include_pip_general_options;

# shellcheck disable=SC1091
. rapids-generate-docstring;

build_${PY_LIB}_python_wheel() {
    local -;
    set -euo pipefail;

    export ${PY_ENV} PATH="$PATH";

    eval "$(                                          \
    PARALLEL_LEVEL=${PARALLEL_LEVEL:-$(nproc --all)}  \
        rapids-get-num-archs-jobs-and-load "$@"       \
        2>/dev/null                                   \
    )";

    local py_lib="${PY_LIB}";

    local -a cmake_args_="(${CMAKE_ARGS:-})";
    cmake_args_+=(${CPP_CMAKE_ARGS});

    local -a pip_args_=(${PIP_WHEEL_ARGS});

    eval "$(_parse_args --take '-G -v,--verbose' "$@" "${cmake_args_[@]}" "${pip_args_[@]}" <&0)";

    if [[ ! -d "${PY_SRC}" ]]; then
        echo "build-${PY_LIB}-python-wheel: cannot access '${PY_SRC}': No such directory" >&2;
        exit 1;
    fi

    # shellcheck disable=SC1091
    . devcontainer-utils-debug-output 'rapids_build_utils_debug' 'build-all build-${NAME} build-${PY_LIB}-python build-${PY_LIB}-python-wheel';

    local -a cmake_args="(
        -G\"${G:-Ninja}\"
        ${cmake_args_[*]@Q}
        ${CPP_DEPS}
        ${v:+--log-level=VERBOSE}
        $(rapids-select-cmake-args "$@")
    )";

    local ninja_args=();

    if test -n "${v-}"; then
        ninja_args+=("-v");
    fi

    if test -n "${n_jobs-}"; then
        ninja_args+=("-j${n_jobs}");
    fi

    if test -n "${n_load-}"; then
        ninja_args+=("-l${n_load}");
    fi

    local -a pip_args="(
        ${pip_args_+"${pip_args_[*]@Q}"}
        $(rapids-select-pip-wheel-args "$@")
    )";

    if rapids-python-uses-scikit-build "${PY_SRC}"; then
        # Clean the `_skbuild/.../cmake-build` dir if configuration failed before
        if ! test -d "$(rapids-maybe-clean-build-dir "${cmake_args[@]}" -- "${PY_SRC}")"; then
            rm -rf "${PY_SRC}/_skbuild";
        fi
    elif rapids-python-uses-scikit-build-core "${PY_SRC}"; then
        pip_args+=(-C "build-dir=$(rapids-maybe-clean-build-dir "${cmake_args[@]}" -- "${PY_SRC}")");
    fi

    pip_args+=("${PY_SRC}");

    trap "rm -rf '${PY_SRC}/${py_lib//"-"/"_"}.egg-info'" EXIT;

    time (
        local cudaflags="${CUDAFLAGS:+$CUDAFLAGS }-t=${n_arch}";
        local build_type="$(rapids-select-cmake-build-type "${cmake_args_[@]}")";
        local nvcc_append_flags="${NVCC_APPEND_FLAGS:+$NVCC_APPEND_FLAGS }-t=${n_arch}";

        # SKBUILD_BUILD_TOOL_ARGS="${ninja_args[*]}"   \
        CUDAFLAGS="${cudaflags}"                     \
        CMAKE_GENERATOR="${G:-Ninja}"                \
        PARALLEL_LEVEL="${n_jobs}"                   \
        CMAKE_ARGS="${cmake_args[*]@Q}"              \
        SKBUILD_BUILD_OPTIONS="${ninja_args[*]}"     \
        SKBUILD_LOGGING_LEVEL="${v:+INFO}"           \
        SKBUILD_INSTALL_STRIP="${strip:+True}"       \
        SKBUILD_CMAKE_VERBOSE="${v:+True}"           \
        SKBUILD_CMAKE_BUILD_TYPE="${build_type}"     \
        CMAKE_BUILD_PARALLEL_LEVEL="${n_jobs}"       \
        NVCC_APPEND_FLAGS="${nvcc_append_flags}"     \
            python -m pip wheel "${pip_args[@]}"     \
        ;
        { set +x; } 2>/dev/null; echo -n "${PY_LIB} wheel build time:";
    ) 2>&1;
}

build_${PY_LIB}_python_wheel "$@" <&0;
