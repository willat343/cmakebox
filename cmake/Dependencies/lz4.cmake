# Import lz4 as:
#   import_lz4(
#        VERSION <STRING:version>
#   )
#
# Link to LZ4::lz4 target with:
#   target_link_libraries(<target> <INTERFACE|PUBLIC|PRIVATE> LZ4::lz4)
function(import_lz4)
    set(OPTIONS)
    set(SINGLE_VALUE_ARGS
        VERSION
    )
    set(MULTI_VALUE_ARGS)
    cmake_parse_arguments(
        DEPENDENCY
        "${OPTIONS}"
        "${SINGLE_VALUE_ARGS}"
        "${MULTI_VALUE_ARGS}"
        ${ARGN}
    )

    import_dependency(
        lz4
        TARGET LZ4::lz4
        VERSION ${DEPENDENCY_VERSION}
        GIT_REPOSITORY https://github.com/lz4/lz4.git
        GIT_TAG v${DEPENDENCY_VERSION}
        SOURCE_SUBDIR build/cmake
    )

    # TODO: use install/export insights from https://apache.googlesource.com/nifi-minifi-cpp/+/HEAD/cmake/LZ4.cmake
    if (NOT TARGET LZ4::lz4)
        add_library(LZ4::lz4 ALIAS lz4)
    endif()
endfunction()
