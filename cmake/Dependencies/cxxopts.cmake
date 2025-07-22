# Import cxxopts as:
#   import_cxxopts(
#        VERSION <STRING:version>
#        [USE_FIND_PACKAGE]
#   )
#
# Link to cxxopts::cxxopts target with:
#   target_link_libraries(<target> <INTERFACE|PUBLIC|PRIVATE> cxxopts::cxxopts)
function(import_cxxopts)
    set(OPTIONS
        USE_FIND_PACKAGE
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

    import_dependency(
        cxxopts
        TARGET cxxopts::cxxopts
        VERSION ${DEPENDENCY_VERSION}
        GIT_REPOSITORY https://github.com/jarro2783/cxxopts.git
        GIT_TAG v${DEPENDENCY_VERSION}
        ${OUTPUT_OPTIONS}
    )
endfunction()
