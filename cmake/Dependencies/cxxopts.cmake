# Import cxxopts as:
#   import_cxxopts(
#        VERSION <STRING:version>
#        [METHOD <STRING:FIND_PACKAGE|FETCH_GIT>]
#   )
#
# Tested VERSIONs: 3.3.1
#
# Default METHOD is FETCH_GIT.
#
# Link to cxxopts::cxxopts target with:
#   target_link_libraries(<target> <INTERFACE|PUBLIC|PRIVATE> cxxopts::cxxopts)
function(import_cxxopts)
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
        cxxopts
        TARGET cxxopts::cxxopts
        METHOD ${DEPENDENCY_METHOD}
        FIND_PACKAGE_VERSION ${DEPENDENCY_VERSION}
        GIT_REPOSITORY https://github.com/jarro2783/cxxopts.git
        GIT_TAG v${DEPENDENCY_VERSION}
    )
endfunction()
