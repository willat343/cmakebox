# Import nlohmann_json_schema_validator as:
#   import_nlohmann_json_schema_validator(
#        VERSION <STRING:version>
#        [METHOD <STRING:FIND_PACKAGE|FETCH_GIT>]
#   )
#
# Tested VERSIONs: 2.3.0
#
# Default METHOD is FETCH_GIT.
#
# If this is called before or without import_nlohmann_json(...), then nlohmann_json 3.8.0 will be fetched. If
# import_nlohmann_json(...) was called, then the VERSION should be >= 3.8.0. 
#
# Link to nlohmann_json_schema_validator::validator target with:
#   target_link_libraries(<target> <INTERFACE|PUBLIC|PRIVATE> nlohmann_json_schema_validator::validator)
function(import_nlohmann_json_schema_validator)
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

    if (NOT DEPENDENCY_USE_FIND_PACKAGE AND DEPENDENCY_VERSION VERSION_LESS "2.3.0")
        message(FATAL_ERROR "Must add USE_FIND_PACKAGE for VERSION < 2.3.0 because nlohmann_json_schema_validator does "
            "not support FetchContent correctly prior to this version.")
    endif()

    if (NOT TARGET nlohmann_json::nlohmann_json)
        import_nlohmann_json(
            VERSION "3.8.0"
            METHOD ${DEPENDENCY_METHOD}
        )
    endif()

    # Note nlohmann_json_schema_validator_SHARED_LIBS is added due to a bug in release 2.3.0 documented in
    # https://github.com/pboettch/json-schema-validator/issues/359
    import_dependency(
        nlohmann_json_schema_validator
        TARGET nlohmann_json_schema_validator::validator
        METHOD ${DEPENDENCY_METHOD}
        FIND_PACKAGE_VERSION ${DEPENDENCY_VERSION}
        GIT_REPOSITORY https://github.com/pboettch/json-schema-validator.git
        GIT_TAG ${DEPENDENCY_VERSION}
        ENABLE_CACHE_VARIABLES JSON_VALIDATOR_INSTALL JSON_VALIDATOR_SHARED_LIBS nlohmann_json_schema_validator_SHARED_LIBS
    )
endfunction()
