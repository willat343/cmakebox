# Import nlohmann_json as:
#   import_nlohmann_json(
#        VERSION <STRING:version>
#        [USE_FIND_PACKAGE]
#   )
#
# Link to nlohmann_json::nlohmann_json target with:
#   target_link_libraries(<target> <INTERFACE|PUBLIC|PRIVATE> nlohmann_json::nlohmann_json)
function(import_nlohmann_json)
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
        nlohmann_json
        TARGET nlohmann_json::nlohmann_json
        VERSION ${DEPENDENCY_VERSION}
        USE_FIND_PACKAGE_REQUIRED_VERSION "3.8.0"
        GIT_REPOSITORY https://github.com/nlohmann/json.git
        GIT_TAG v${DEPENDENCY_VERSION}
        ${OUTPUT_OPTIONS}
        DISABLE_CACHE_VARIABLES JSON_BuildTests BUILD_TESTING
    )
endfunction()
