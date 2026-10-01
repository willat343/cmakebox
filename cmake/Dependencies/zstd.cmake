# Import zstd as:
#   import_zstd(
#        VERSION <STRING:version>
#        [METHOD <STRING:FETCH_GIT>]
#   )
#
# Any additional arguments not listed above (e.g. COMPILE_FLAGS and LINK_FLAGS) are forwarded to
# import_dependency(). See CMakeBoxDependencies.cmake for details.
#
# Tested VERSIONs: 1.5.7
#
# Default METHOD is FETCH_GIT.
#
# Link to zstd::libzstd target with:
#   target_link_libraries(<target> <INTERFACE|PUBLIC|PRIVATE> zstd::libzstd)
function(import_zstd)
    set(OPTIONS)
    set(SINGLE_VALUE_ARGS
        VERSION
        METHOD
    )
    set(MULTI_VALUE_ARGS)
    cmake_parse_arguments(
        DEPENDENCY
        "${OPTIONS}"
        "${SINGLE_VALUE_ARGS}"
        "${MULTI_VALUE_ARGS}"
        ${ARGN}
    )

    if (NOT DEPENDENCY_METHOD)
        set(DEPENDENCY_METHOD "FETCH_GIT")
    endif()

    import_dependency(
        zstd
        TARGET zstd::libzstd
        METHOD ${DEPENDENCY_METHOD}
        FIND_PACKAGE_VERSION ${DEPENDENCY_VERSION}
        GIT_REPOSITORY https://github.com/facebook/zstd.git
        GIT_TAG v${DEPENDENCY_VERSION}
        SOURCE_SUBDIR build/cmake
        ${DEPENDENCY_UNPARSED_ARGUMENTS}
    )

    # TODO: install/export
    if (NOT TARGET zstd::libzstd)
        add_library(zstd::libzstd ALIAS libzstd)
    endif()
endfunction()
