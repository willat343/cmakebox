# Import nlohmann_json as:
#   import_nlohmann_json(
#        VERSION <STRING:version>
#        [METHOD <STRING:FIND_PACKAGE|FETCH_GIT>]
#   )
#
# Tested VERSIONs: 3.8.0
#
# Default METHOD is FETCH_GIT.
#
# Link to nlohmann_json::nlohmann_json target with:
#   target_link_libraries(<target> <INTERFACE|PUBLIC|PRIVATE> nlohmann_json::nlohmann_json)
function(import_nlohmann_json)
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

    if (NOT DEPENDENCY_USE_FIND_PACKAGE AND DEPENDENCY_VERSION VERSION_LESS "3.8.0")
        message(FATAL_ERROR "Must add USE_FIND_PACKAGE for VERSION < 3.8.0 because nlohmann_json does not support "
            "FetchContent correctly prior to this version.")
    endif()

    import_dependency(
        nlohmann_json
        TARGET nlohmann_json::nlohmann_json
        METHOD ${DEPENDENCY_METHOD}
        FIND_PACKAGE_VERSION ${DEPENDENCY_VERSION}
        GIT_REPOSITORY https://github.com/nlohmann/json.git
        GIT_TAG v${DEPENDENCY_VERSION}
        DISABLE_CACHE_VARIABLES JSON_BuildTests BUILD_TESTING
    )
endfunction()
