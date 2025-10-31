# Import foxglove-sdk's schemas as:
#   import_foxglove_schemas(
#        VERSION <STRING:version>
#        [METHOD <STRING:FETCH_GIT>]
#   )
#
# Tested VERSIONs: 0.10.1
#
# Default METHOD is FETCH_GIT.
#
# Only the source files
function(import_foxglove_schemas)
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

    if (DEPENDENCY_METHOD STREQUAL "FETCH_GIT")
        FetchContent_Declare(
            foxglove_schemas
            GIT_REPOSITORY https://github.com/foxglove/foxglove-sdk.git
            GIT_TAG        sdk/v${DEPENDENCY_VERSION}
            SOURCE_SUBDIR  schemas
            OVERRIDE_FIND_PACKAGE
        )
    else()
        message(FATAL_ERROR "METHOD ${DEPENDENCY_METHOD}")
    endif()
    FetchContent_MakeAvailable(foxglove_schemas)
    message(STATUS "Fetched foxglove_schemas to ${foxglove_schemas_SOURCE_DIR}.")

    set(foxglove_schemas_FOUND "YES" CACHE STRING "foxglove_schemas was imported" FORCE)
    set(foxglove_schemas_DIR ${foxglove_schemas_SOURCE_DIR} CACHE STRING
        "foxglove_schemas directory" FORCE)
endfunction()
