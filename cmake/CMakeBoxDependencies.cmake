

# Import Dependency as:
#   import_dependency(
#        <dependency_name>
#        TARGET <STRING:target>
#        VERSION <STRING:version>
#        GIT_REPOSITORY <STRING:repository>
#        GIT_TAG <STRING:tag/branch/commit>
#        [SOURCE_SUBDIR <STRING:path_to_CMakelists.txt>]
#        [USE_FIND_PACKAGE_REQUIRED_VERSION <STRING:version>]
#        [USE_FIND_PACKAGE]
#        [DISABLE_CACHE_VARS <VAR1> [<VAR2> ...]]
#        [ENABLE_CACHE_VARS <VAR1> [<VAR2> ...]]
#   )
function(import_dependency DEPENDENCY)
    set(OPTIONS
        USE_FIND_PACKAGE
    )
    set(SINGLE_VALUE_ARGS
        TARGET
        VERSION
        USE_FIND_PACKAGE_REQUIRED_VERSION
        GIT_REPOSITORY
        GIT_TAG
        SOURCE_SUBDIR
    )
    set(MULTI_VALUE_ARGS
        DISABLE_CACHE_VARIABLES
        ENABLE_CACHE_VARIABLES
    )
    cmake_parse_arguments(
        DEPENDENCY
        "${OPTIONS}"
        "${SINGLE_VALUE_ARGS}"
        "${MULTI_VALUE_ARGS}"
        ${ARGN}
    )
    string(TOLOWER ${DEPENDENCY} DEPENDENCY_LOWERCASE)
    string(TOUPPER ${DEPENDENCY} DEPENDENCY_UPPERCASE)

    if(NOT DEPENDENCY_SOURCE_SUBDIR)
        set(DEPENDENCY_SOURCE_SUBDIR ".")
    endif()

    if (NOT DEPENDENCY_TARGET)
        message(FATAL_ERROR "Missing argument TARGET for import_dependency ${DEPENDENCY}")
    endif()

    if (DEPENDENCY_USE_FIND_PACKAGE_REQUIRED_VERSION AND NOT DEPENDENCY_USE_FIND_PACKAGE
            AND DEPENDENCY_VERSION VERSION_LESS DEPENDENCY_USE_FIND_PACKAGE_REQUIRED_VERSION)
        message(FATAL_ERROR "Must use USE_FIND_PACKAGE flag for ${DEPENDENCY} VERSION < "
            "${DEPENDENCY_USE_FIND_PACKAGE_REQUIRED_VERSION}. ${DEPENDENCY} does not support FetchContent prior to "
            "this release. Requested VERSION was ${DEPENDENCY_VERSION}.")
    endif()

    if (NOT TARGET ${DEPENDENCY_TARGET})
        message(STATUS
            "Importing ${DEPENDENCY} (Target: ${DEPENDENCY_TARGET}, USE_FIND_PACKAGE = ${DEPENDENCY_USE_FIND_PACKAGE})")
        if (DEPENDENCY_USE_FIND_PACKAGE)
            message(STATUS "    VERSION=${DEPENDENCY_VERSION}")
            if (DEPENDENCY_USE_FIND_PACKAGE_REQUIRED_VERSION)
                message(VERBOSE "    USE_FIND_PACKAGE_REQUIRED_VERSION=${DEPENDENCY_USE_FIND_PACKAGE_REQUIRED_VERSION}")
            endif()
        else()
            if (FETCHCONTENT_SOURCE_DIR_${DEPENDENCY_UPPERCASE})
                message(STATUS "    FETCHCONTENT_SOURCE_DIR=${FETCHCONTENT_SOURCE_DIR_${DEPENDENCY_UPPERCASE}}")
            else()
                message(STATUS "    GIT_REPOSITORY=${DEPENDENCY_GIT_REPOSITORY}")
                message(STATUS "    GIT_TAG=${DEPENDENCY_GIT_TAG}")
            endif()
            message(VERBOSE "    SOURCE_SUBDIR=${DEPENDENCY_SOURCE_SUBDIR}")
            message(VERBOSE "    DISABLE_CACHE_VARIABLES=${DEPENDENCY_DISABLE_CACHE_VARIABLES}")
            message(VERBOSE "    ENABLE_CACHE_VARIABLES=${DEPENDENCY_ENABLE_CACHE_VARIABLES}")
        endif()

        if (DEPENDENCY_USE_FIND_PACKAGE)
            if (NOT DEPENDENCY_VERSION)
                message(FATAL_ERROR "Missing VERSION for dependency ${DEPENDENCY}")
            endif()
            find_package(${DEPENDENCY} ${DEPENDENCY_VERSION} REQUIRED)
            message(STATUS "Found ${DEPENDENCY} at ${${DEPENDENCY}_DIR} with version ${${DEPENDENCY}_VERSION}")
        else()
            if (DEPENDENCY_DISABLE_CACHE_VARIABLES)
                disable_cache_variables(${DEPENDENCY_DISABLE_CACHE_VARIABLES})
            endif()
            if (DEPENDENCY_ENABLE_CACHE_VARIABLES)
                enable_cache_variables(${DEPENDENCY_ENABLE_CACHE_VARIABLES})
            endif()
            if (NOT DEPENDENCY_GIT_REPOSITORY OR NOT DEPENDENCY_GIT_TAG)
                message(FATAL_ERROR "Missing GIT_REPOSITORY or GIT_TAG for dependency ${DEPENDENCY}")
            endif()
            FetchContent_Declare(
                ${DEPENDENCY}
                GIT_REPOSITORY ${DEPENDENCY_GIT_REPOSITORY}
                GIT_TAG        ${DEPENDENCY_GIT_TAG}
                SOURCE_SUBDIR  ${DEPENDENCY_SOURCE_SUBDIR}
                OVERRIDE_FIND_PACKAGE
            )
            if (FETCHCONTENT_SOURCE_DIR_${DEPENDENCY_UPPERCASE} AND NOT EXISTS
                    ${FETCHCONTENT_SOURCE_DIR_${DEPENDENCY_UPPERCASE}})
                message(FATAL_ERROR
                    "FETCHCONTENT_SOURCE_DIR_${DEPENDENCY_UPPERCASE} was specified as "
                    "${FETCHCONTENT_SOURCE_DIR_${DEPENDENCY_UPPERCASE}} but no directory was found. The user is "
                    "resposible for downloading code to a specified FETCHCONTENT_SOURCE_DIR_${DEPENDENCY_UPPERCASE}.")
            endif()
            FetchContent_MakeAvailable(${DEPENDENCY})
            set(${DEPENDENCY}_FOUND "YES" CACHE STRING "${DEPENDENCY} was imported" FORCE)
            set(${DEPENDENCY}_DIR ${${DEPENDENCY}_BINARY_DIR} CACHE STRING "${DEPENDENCY} directory" FORCE)
            message(STATUS
                "Fetched ${DEPENDENCY} to ${${DEPENDENCY_LOWERCASE}_SOURCE_DIR} with tag ${DEPENDENCY_GIT_TAG}")
            if (DEPENDENCY_DISABLE_CACHE_VARIABLES)
                restore_cache_variables(${DEPENDENCY_DISABLE_CACHE_VARIABLES})
            endif()
            if (DEPENDENCY_ENABLE_CACHE_VARIABLES)
                restore_cache_variables(${DEPENDENCY_ENABLE_CACHE_VARIABLES})
            endif()
        endif()
    else()
        message(STATUS "${DEPENDENCY} (Target: ${DEPENDENCY_TARGET}) already imported.")
    endif()
endfunction()

include(Dependencies/Ceres)
include(Dependencies/cxxopts)
include(Dependencies/Eigen3)
include(Dependencies/lz4)
include(Dependencies/manif)
include(Dependencies/nlohmann_json)
include(Dependencies/mcap)
include(Dependencies/zstd)
