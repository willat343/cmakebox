# Import Ceres as:
#   import_Ceres(
#        VERSION <STRING:version>
#        [USE_FIND_PACKAGE]
#   )
#
# Link to Ceres::ceres target with:
#   target_link_libraries(<target> <INTERFACE|PUBLIC|PRIVATE> Ceres::ceres)
function(import_Ceres)
    set(OPTIONS
        USE_FIND_PACKAGE
    )
    set(SINGLE_VALUE_ARGS
        VERSION
        Eigen3_DIR
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
        Ceres
        TARGET Ceres::ceres
        VERSION ${DEPENDENCY_VERSION}
        USE_FIND_PACKAGE_REQUIRED_VERSION "2.2.0"
        GIT_REPOSITORY https://github.com/ceres-solver/ceres-solver.git
        GIT_TAG ${DEPENDENCY_VERSION}
        ${OUTPUT_OPTIONS}
        DISABLE_CACHE_VARIABLES BUILD_BENCHMARKS BUILD_TESTING BUILD_EXAMPLES PROVIDE_UNINSTALL_TARGET
        ENABLE_CACHE_VARIABLES EXPORT_BUILD_DIR
    )
endfunction()
