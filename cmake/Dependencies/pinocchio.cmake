# Import pinocchio as:
#   import_pinocchio(
#        VERSION <STRING:version>
#        [METHOD <STRING:FETCH_GIT>]
#   )
#
# Default METHOD is GIT.
#
# Link to pinocchio::pinocchio target with:
#   target_link_libraries(<target> <INTERFACE|PUBLIC|PRIVATE> pinocchio::pinocchio)
function(import_pinocchio)
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
        pinocchio
        TARGET pinocchio::pinocchio
        METHOD ${DEPENDENCY_METHOD}
        FIND_PACKAGE_VERSION ${DEPENDENCY_VERSION}
        GIT_REPOSITORY https://github.com/stack-of-tasks/pinocchio.git
        GIT_TAG v${DEPENDENCY_VERSION}
        DISABLE_CACHE_VARIABLES BUILD_TESTING BUILD_EXAMPLES BUILD_PYTHON_INTERFACE
    )
endfunction()
