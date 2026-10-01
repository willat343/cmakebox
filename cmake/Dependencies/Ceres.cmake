# Import Ceres as:
#   import_Ceres(
#        VERSION <STRING:version>
#        [METHOD <STRING:FIND_PACKAGE|FETCH_GIT>]
#   )
#
# Any additional arguments not listed above (e.g. COMPILE_FLAGS and LINK_FLAGS) are forwarded to
# import_dependency(). See CMakeBoxDependencies.cmake for details.
#
# Tested VERSIONs: 2.2.0
#
# Default METHOD is FETCH_GIT.
#
# When fetching, MINIGLOG is enabled for Ceres if Google Log (glog) cannot be found.
#
# Link to Ceres::ceres target with:
#   target_link_libraries(<target> <INTERFACE|PUBLIC|PRIVATE> Ceres::ceres)
function(import_Ceres)
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

    if (NOT DEPENDENCY_USE_FIND_PACKAGE AND DEPENDENCY_VERSION VERSION_LESS "2.2.0")
        message(FATAL_ERROR "Must add USE_FIND_PACKAGE for VERSION < 2.2.0 because Ceres does not support FetchContent "
            "correctly prior to this version.")
    endif()

    # Ceres requires glog when built from source, unless its minimal glog substitute (MINIGLOG) is enabled.
    set(ENABLE_MINIGLOG)
    if (NOT DEPENDENCY_METHOD STREQUAL "FIND_PACKAGE" AND NOT MINIGLOG)
        find_system_dependencies(MISSING LIBRARIES glog HEADERS glog/logging.h)
        if (MISSING)
            message(STATUS "Google Log (glog) not found. Enabling MINIGLOG for Ceres.")
            set(ENABLE_MINIGLOG MINIGLOG)
        endif()
    endif()

    # USE_CUDA has been disabled due to this bug in Ceres: https://github.com/ceres-solver/ceres-solver/issues/1188
    import_dependency(
        Ceres
        TARGET Ceres::ceres
        METHOD ${DEPENDENCY_METHOD}
        FIND_PACKAGE_VERSION ${DEPENDENCY_VERSION}
        GIT_REPOSITORY https://github.com/ceres-solver/ceres-solver.git
        GIT_TAG ${DEPENDENCY_VERSION}
        DISABLE_CACHE_VARIABLES BUILD_BENCHMARKS BUILD_DOCUMENTATION BUILD_EXAMPLES BUILD_TESTING PROVIDE_UNINSTALL_TARGET USE_CUDA
        ENABLE_CACHE_VARIABLES EXPORT_BUILD_DIR ${ENABLE_MINIGLOG}
        ${DEPENDENCY_UNPARSED_ARGUMENTS}
    )
endfunction()
