# Import manif as:
#   import_manif(
#        VERSION <STRING:version>
#        [METHOD <STRING:FETCH_GIT>]
#        [FORK]
#   )
#
# Any additional arguments not listed above (e.g. COMPILE_FLAGS and LINK_FLAGS) are forwarded to
# import_dependency(). See CMakeBoxDependencies.cmake for details.
#
# Without FORK, VERSION X.Y.Z is fetched as the release X.Y.Z of https://github.com/artivis/manif.
#
# With FORK, VERSION X.Y.Z.N is fetched as the tag X.Y.Z.N of the fork https://github.com/willat343/manif, which is the
# N-th revision of the fork's `integration` branch since the upstream release X.Y.Z. The `integration` branch is the
# upstream `devel` branch merged with the fork's branches that are open as upstream pull requests, so that fixes can be
# used before they are merged and released upstream. Versions order as X.Y.Z < X.Y.Z.N < X.Y.(Z+1).
#
# Tested VERSIONs: 0.0.5.1 (FORK), 0.0.5.2 (FORK)
#
# Default METHOD is FETCH_GIT.
#
# Link to MANIF::manif target with:
#   target_link_libraries(<target> <INTERFACE|PUBLIC|PRIVATE> MANIF::manif)
function(import_manif)
    set(OPTIONS
        FORK
    )
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

    if (DEPENDENCY_FORK)
        set(MANIF_GIT_REPOSITORY https://github.com/willat343/manif.git)
    else()
        set(MANIF_GIT_REPOSITORY https://github.com/artivis/manif.git)
        # Upstream releases up to 0.0.5 cannot be fetched (see https://github.com/artivis/manif/pull/332). Which later
        # release can is not yet known, so this check must be revisited when one is made.
        if (NOT DEPENDENCY_METHOD STREQUAL "FIND_PACKAGE" AND DEPENDENCY_VERSION VERSION_LESS_EQUAL "0.0.5")
            message(FATAL_ERROR "Must use METHOD FIND_PACKAGE or FORK for VERSION <= 0.0.5 because upstream manif "
                "releases up to 0.0.5 do not support FetchContent correctly.")
        endif()
    endif()

    import_dependency(
        manif
        TARGET MANIF::manif
        METHOD ${DEPENDENCY_METHOD}
        FIND_PACKAGE_VERSION ${DEPENDENCY_VERSION}
        GIT_REPOSITORY ${MANIF_GIT_REPOSITORY}
        GIT_TAG ${DEPENDENCY_VERSION}
        DISABLE_CACHE_VARIABLES BUILD_TESTING BUILD_EXAMPLES
        ${DEPENDENCY_UNPARSED_ARGUMENTS}
    )
endfunction()
