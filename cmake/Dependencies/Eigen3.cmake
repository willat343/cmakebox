# Import Eigen3 as:
#   import_Eigen3(
#        VERSION <STRING:version>
#        [USE_FIND_PACKAGE]
#   )
#
# Link to Eigen3::Eigen target with:
#   target_link_libraries(<target> <INTERFACE|PUBLIC|PRIVATE> Eigen3::Eigen)
function(import_Eigen3)
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

    if (NOT TARGET Eigen3::Eigen AND NOT DEPENDENCY_USE_FIND_PACKAGE AND DEPENDENCY_VERSION VERSION_LESS "3.5.0")
        message(AUTHOR_WARNING "Fetching Eigen3 ${DEPENDENCY_VERSION} which defines an uninstall target that "
            "may interfere with other projects. This is fixed from VERSION 3.5.0 "
            "(Issue: https://gitlab.com/libeigen/eigen/-/issues/1892, "
            "Merge Request: https://gitlab.com/libeigen/eigen/-/merge_requests/1885).")
    endif()

    import_dependency(
        Eigen3
        TARGET Eigen3::Eigen
        VERSION ${DEPENDENCY_VERSION}
        USE_FIND_PACKAGE_REQUIRED_VERSION "3.4.0"
        GIT_REPOSITORY https://gitlab.com/libeigen/eigen.git
        GIT_TAG ${DEPENDENCY_VERSION}
        ${OUTPUT_OPTIONS}
        DISABLE_CACHE_VARIABLES BUILD_TESTING BUILD_EXAMPLES
    )
endfunction()
