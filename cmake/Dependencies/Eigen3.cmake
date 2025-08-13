# Import Eigen3 as:
#   import_Eigen3(
#        VERSION <STRING:version>
#        [METHOD <STRING:FIND_PACKAGE|FETCH_GIT>]
#   )
#
# Tested VERSIONs: 3.4.0
#
# Default METHOD is FETCH_GIT.
#
# Link to Eigen3::Eigen target with:
#   target_link_libraries(<target> <INTERFACE|PUBLIC|PRIVATE> Eigen3::Eigen)
function(import_Eigen3)
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

    if (NOT DEPENDENCY_USE_FIND_PACKAGE AND DEPENDENCY_VERSION VERSION_LESS "3.4.0")
        message(FATAL_ERROR "Must add USE_FIND_PACKAGE for VERSION < 3.4.0 because Eigen3 does not support "
            "FetchContent correctly prior to this version.")
    endif()

    if (NOT TARGET Eigen3::Eigen AND NOT DEPENDENCY_USE_FIND_PACKAGE AND DEPENDENCY_VERSION VERSION_LESS "3.5.0")
        message(AUTHOR_WARNING "Fetching Eigen3 ${DEPENDENCY_VERSION} which defines an uninstall target that "
            "may interfere with other projects. This is fixed from VERSION 3.5.0 "
            "(Issue: https://gitlab.com/libeigen/eigen/-/issues/1892, "
            "Merge Request: https://gitlab.com/libeigen/eigen/-/merge_requests/1885).")
    endif()

    import_dependency(
        Eigen3
        TARGET Eigen3::Eigen
        METHOD ${DEPENDENCY_METHOD}
        FIND_PACKAGE_VERSION ${DEPENDENCY_VERSION}
        GIT_REPOSITORY https://gitlab.com/libeigen/eigen.git
        GIT_TAG ${DEPENDENCY_VERSION}
        DISABLE_CACHE_VARIABLES BUILD_TESTING BUILD_EXAMPLES
    )
endfunction()
