# Import httplib as:
#   import_httplib(
#        VERSION <STRING:version>
#        [METHOD <STRING:FIND_PACKAGE|FETCH_GIT>]
#   )
#
# Tested VERSIONs: 0.25.0
#
# Default METHOD is FETCH_GIT.
#
# Link to httplib::httplib target with:
#   target_link_libraries(<target> <INTERFACE|PUBLIC|PRIVATE> httplib::httplib)
function(import_httplib)
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
        httplib
        TARGET httplib::httplib
        METHOD ${DEPENDENCY_METHOD}
        FIND_PACKAGE_VERSION ${DEPENDENCY_VERSION}
        GIT_REPOSITORY https://github.com/yhirose/cpp-httplib.git
        GIT_TAG v${DEPENDENCY_VERSION}
        DISABLE_CACHE_VARIABLES HTTPLIB_USE_NON_BLOCKING_GETADDRINFO
    )
endfunction()
