# Import manif as:
#   import_manif(
#        VERSION <STRING:version>
#        [USE_SYSTEM]
#   )
#
# Link to MANIF::manif target with:
#   target_link_libraries(<target> <INTERFACE|PUBLIC|PRIVATE> MANIF::manif)
function(import_manif)
    set(OPTIONS
        USE_SYSTEM
    )
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

    set(OUTPUT_OPTIONS)
    foreach(OPTION ${OPTIONS})
        if (DEPENDENCY_${OPTION})
            list(APPEND OUTPUT_OPTIONS ${OPTION})
        endif()
    endforeach()

    # TODO: switch repo from fork and switch ${DEPENDENCY_VERSION} after PR https://github.com/artivis/manif/pull/332
    import_dependency(
        manif
        TARGET MANIF::manif
        VERSION ${DEPENDENCY_VERSION}
        USE_SYSTEM_REQUIRED_VERSION "0.0.6"
        GIT_REPOSITORY https://github.com/willat343/manif.git
        GIT_TAG feature/cmake_fetchcontent_support # i.e. 6e6dc6dd36171dac79e3f7f56713a86adc9eafd5
        ${OUTPUT_OPTIONS}
        DISABLE_CACHE_VARIABLES BUILD_TESTING BUILD_EXAMPLES
    )
endfunction()
