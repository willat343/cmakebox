# Import doxygen as:
#   import_doxygen(
#        VERSION <STRING:version>
#        [METHOD <STRING:FIND_PACKAGE|FETCH_GIT>]
#   )
#
# Any additional arguments not listed above (e.g. COMPILE_FLAGS and LINK_FLAGS) are forwarded to
# import_dependency(). See CMakeBoxDependencies.cmake for details.
#
# Tested VERSIONs: 3.3.1
#
# Default METHOD is FETCH_GIT.
#
# When fetching, building doxygen from source requires bison, flex and python3 to be installed on the system (e.g.
# `sudo apt install bison flex python3`).
#
# This creates a target doxygen, which should be made a dependency of the documentation target with:
#   add_dependencies(<documentation_target> doxygen)
function(import_doxygen)
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

    if (NOT DEPENDENCY_METHOD STREQUAL "FIND_PACKAGE")
        find_system_dependencies(MISSING PROGRAMS bison flex python3)
        if (MISSING)
            string(REPLACE ";" " " MISSING "${MISSING}")
            message(FATAL_ERROR "Building doxygen from source requires missing system dependencies "
                "(${MISSING}), which can be installed with:\n  sudo apt install ${MISSING}")
        endif()
    endif()

    string(REPLACE "." ";" DEPENDENCY_VERSION_LIST "${DEPENDENCY_VERSION}")
    list(GET DEPENDENCY_VERSION_LIST 0 DEPENDENCY_VERSION_MAJOR)
    list(GET DEPENDENCY_VERSION_LIST 1 DEPENDENCY_VERSION_MINOR)
    list(GET DEPENDENCY_VERSION_LIST 2 DEPENDENCY_VERSION_PATCH)

    import_dependency(
        Doxygen
        TARGET doxygen
        METHOD ${DEPENDENCY_METHOD}
        FIND_PACKAGE_VERSION ${DEPENDENCY_VERSION}
        GIT_REPOSITORY https://github.com/doxygen/doxygen.git
        GIT_TAG Release_${DEPENDENCY_VERSION_MAJOR}_${DEPENDENCY_VERSION_MINOR}_${DEPENDENCY_VERSION_PATCH}
        ${DEPENDENCY_UNPARSED_ARGUMENTS}
    )

    set(DOXYGEN_EXECUTABLE $<TARGET_FILE:doxygen> PARENT_SCOPE)
endfunction()
