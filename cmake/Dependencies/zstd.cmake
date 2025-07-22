# Import zstd as:
#   import_zstd(
#        VERSION <STRING:version>
#   )
#
# Link to zstd::libzstd target with:
#   target_link_libraries(<target> <INTERFACE|PUBLIC|PRIVATE> zstd::libzstd)
function(import_zstd)
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
        zstd
        TARGET zstd::libzstd
        VERSION ${DEPENDENCY_VERSION}
        GIT_REPOSITORY https://github.com/facebook/zstd.git
        GIT_TAG v${DEPENDENCY_VERSION}
        SOURCE_SUBDIR build/cmake
    )

    # TODO: install/export
    if (NOT TARGET zstd::libzstd)
        add_library(zstd::libzstd ALIAS libzstd)
    endif()
endfunction()
