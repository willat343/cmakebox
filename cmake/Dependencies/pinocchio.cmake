# Import pinocchio as:
#   import_pinocchio(
#        VERSION <STRING:version>
#        [METHOD <STRING:FETCH_GIT>]
#   )
#
# Any additional arguments not listed above (e.g. COMPILE_FLAGS and LINK_FLAGS) are forwarded to
# import_dependency(). See CMakeBoxDependencies.cmake for details.
#
# Tested VERSIONs: 3.7.0
#
# Default METHOD is FETCH_GIT.
#
# When fetching, building pinocchio from source requires the Boost filesystem, serialization and system libraries to be
# installed on the system (e.g. `sudo apt install libboost-filesystem-dev libboost-serialization-dev
# libboost-system-dev`), as well as urdfdom and urdfdom_headers when building with URDF support
# (BUILD_WITH_URDF_SUPPORT, default ON) (e.g. `sudo apt install liburdfdom-dev`).
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

    # Pinocchio requires Boost, and its URDF support (BUILD_WITH_URDF_SUPPORT, default ON) requires urdfdom and
    # urdfdom_headers.
    if (NOT DEPENDENCY_METHOD STREQUAL "FIND_PACKAGE")
        set(LIBRARIES boost_filesystem boost_serialization boost_system)
        set(HEADERS boost/version.hpp)
        set(PACKAGES libboost-filesystem-dev libboost-serialization-dev libboost-system-dev)
        if (NOT DEFINED BUILD_WITH_URDF_SUPPORT OR BUILD_WITH_URDF_SUPPORT)
            list(APPEND LIBRARIES urdfdom_model)
            list(APPEND HEADERS urdf_model/model.h)
            list(APPEND PACKAGES liburdfdom-dev)
        endif()
        find_system_dependencies(MISSING LIBRARIES ${LIBRARIES} HEADERS ${HEADERS})
        if (MISSING)
            string(REPLACE ";" " " MISSING "${MISSING}")
            string(REPLACE ";" " " PACKAGES "${PACKAGES}")
            message(FATAL_ERROR "Building pinocchio from source requires missing system dependencies (${MISSING}), "
                "which can be installed with:\n  sudo apt install ${PACKAGES}")
        endif()
    endif()

    import_dependency(
        pinocchio
        TARGET pinocchio::pinocchio
        METHOD ${DEPENDENCY_METHOD}
        FIND_PACKAGE_VERSION ${DEPENDENCY_VERSION}
        GIT_REPOSITORY https://github.com/stack-of-tasks/pinocchio.git
        GIT_TAG v${DEPENDENCY_VERSION}
        DISABLE_CACHE_VARIABLES BUILD_TESTING BUILD_EXAMPLES BUILD_PYTHON_INTERFACE
        ${DEPENDENCY_UNPARSED_ARGUMENTS}
    )
endfunction()
