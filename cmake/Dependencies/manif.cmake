# Import manif as:
#   import_manif(
#        VERSION <STRING:version>
#        [METHOD <STRING:FETCH_GIT>]
#   )
#
# Default METHOD is GIT.
#
# Link to MANIF::manif target with:
#   target_link_libraries(<target> <INTERFACE|PUBLIC|PRIVATE> MANIF::manif)
function(import_manif)
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

    if (NOT DEPENDENCY_USE_FIND_PACKAGE AND DEPENDENCY_VERSION VERSION_LESS "0.0.6")
        message(FATAL_ERROR "Must add USE_FIND_PACKAGE for VERSION < 0.0.6 because manif does not support FetchContent "
            "correctly prior to this version.")
    endif()

    # TODO: switch repo from fork and switch ${DEPENDENCY_VERSION} after PR https://github.com/artivis/manif/pull/332
    import_dependency(
        manif
        TARGET MANIF::manif
        METHOD ${DEPENDENCY_METHOD}
        FIND_PACKAGE_VERSION ${DEPENDENCY_VERSION}
        GIT_REPOSITORY https://github.com/willat343/manif.git
        GIT_TAG temp/fix/pedantic_warnings
        DISABLE_CACHE_VARIABLES BUILD_TESTING BUILD_EXAMPLES
    )
endfunction()
