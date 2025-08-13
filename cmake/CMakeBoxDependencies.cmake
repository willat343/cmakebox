

# Import Dependency as:
#   import_dependency(
#        <dependency_name>
#        TARGET <STRING:target>
#        METHOD <STRING:FIND_PACKAGE|FETCH_GIT|FETCH_URL>
#        [FIND_PACKAGE_VERSION <STRING:version>]
#        [GIT_REPOSITORY <STRING:repository>]
#        [GIT_TAG <STRING:tag/branch/commit>]
#        [SOURCE_SUBDIR <STRING:path_to_CMakelists.txt>]
#        [URL <STRING:url>]
#        [URL_HASH <STRING:hash_algorithm=hash>]
#        [DISABLE_CACHE_VARS <VAR1> [<VAR2> ...]]
#        [ENABLE_CACHE_VARS <VAR1> [<VAR2> ...]]
#   )
function(import_dependency DEPENDENCY)
    # Parse Inputs
    set(OPTIONS)
    set(SINGLE_VALUE_ARGS
        TARGET
        METHOD
        FIND_PACKAGE_VERSION
        GIT_REPOSITORY
        GIT_TAG
        SOURCE_SUBDIR
        URL
        URL_HASH
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

    # Set defaults and check inputs
    if(NOT DEPENDENCY_SOURCE_SUBDIR)
        set(DEPENDENCY_SOURCE_SUBDIR ".")
    endif()
    if (NOT DEPENDENCY_TARGET)
        message(FATAL_ERROR "Missing argument TARGET for import_dependency(${DEPENDENCY}).")
    endif()
    if (DEPENDENCY_METHOD STREQUAL "FETCH_GIT")
        if (NOT DEPENDENCY_GIT_REPOSITORY)
            message(FATAL_ERROR "Missing argument GIT_REPOSITORY when using METHOD ${DEPENDENCY_METHOD} for "
                "import_dependency(${DEPENDENCY})")
        endif()
        if (NOT DEPENDENCY_GIT_TAG)
            message(FATAL_ERROR "Missing argument GIT_TAG when using METHOD ${DEPENDENCY_METHOD} for "
                "import_dependency(${DEPENDENCY})")
        endif()
    elseif(DEPENDENCY_METHOD STREQUAL "FETCH_URL")
        if (NOT DEPENDENCY_URL)
            message(FATAL_ERROR "Missing argument URL when using METHOD ${DEPENDENCY_METHOD} for "
                "import_dependency(${DEPENDENCY})")
        endif()
        if (NOT DEPENDENCY_URL_HASH)
            message(AUTHOR_WARNING "Missing argument URL_HASH when using METHOD ${DEPENDENCY_METHOD} for "
                "import_dependency(${DEPENDENCY}). Including the URL_HASH is highly recommended.")
        endif()
    elseif(NOT DEPENDENCY_METHOD STREQUAL "FIND_PACKAGE")
        message(FATAL_ERROR "METHOD is ${DEPENDENCY_METHOD} which is not one of {FIND_PACKAGE|FETCH_GIT|FETCH_URL} "
            "options for import_dependency(${DEPENDENCY}).")
    endif()

    # Set helpful variables
    string(TOLOWER ${DEPENDENCY} DEPENDENCY_LOWERCASE)
    string(TOUPPER ${DEPENDENCY} DEPENDENCY_UPPERCASE)

    # Import
    if (NOT TARGET ${DEPENDENCY_TARGET})
        message(STATUS "Importing ${DEPENDENCY} (Target: ${DEPENDENCY_TARGET}, METHOD = ${DEPENDENCY_METHOD})")
        if (DEPENDENCY_METHOD STREQUAL "FIND_PACKAGE")
            message(STATUS "    FIND_PACKAGE_VERSION=${DEPENDENCY_FIND_PACKAGE_VERSION}")
            if (NOT DEPENDENCY_FIND_PACKAGE_VERSION)
                message(AUTHOR_WARNING "Missing FIND_PACKAGE_VERSION for dependency ${DEPENDENCY}.")
            endif()
            find_package(${DEPENDENCY} ${DEPENDENCY_FIND_PACKAGE_VERSION} REQUIRED)
            message(STATUS "Found ${DEPENDENCY} at ${${DEPENDENCY}_DIR} with version ${${DEPENDENCY}_VERSION}.")
        else()
            if (FETCHCONTENT_SOURCE_DIR_${DEPENDENCY_UPPERCASE})
                message(STATUS "    FETCHCONTENT_SOURCE_DIR=${FETCHCONTENT_SOURCE_DIR_${DEPENDENCY_UPPERCASE}}")
            elseif(DEPENDENCY_METHOD STREQUAL "FETCH_GIT")
                message(STATUS "    GIT_REPOSITORY=${DEPENDENCY_GIT_REPOSITORY}")
                message(STATUS "    GIT_TAG=${DEPENDENCY_GIT_TAG}")
            elseif(DEPENDENCY_METHOD STREQUAL "FETCH_URL")
                message(STATUS "    URL=${DEPENDENCY_URL}")
                message(STATUS "    URL_HASH=${DEPENDENCY_URL_HASH}")
            endif()
            message(VERBOSE "    SOURCE_SUBDIR=${DEPENDENCY_SOURCE_SUBDIR}")
            message(VERBOSE "    DISABLE_CACHE_VARIABLES=${DEPENDENCY_DISABLE_CACHE_VARIABLES}")
            message(VERBOSE "    ENABLE_CACHE_VARIABLES=${DEPENDENCY_ENABLE_CACHE_VARIABLES}")
            if (DEPENDENCY_DISABLE_CACHE_VARIABLES)
                disable_cache_variables(${DEPENDENCY_DISABLE_CACHE_VARIABLES})
            endif()
            if (DEPENDENCY_ENABLE_CACHE_VARIABLES)
                enable_cache_variables(${DEPENDENCY_ENABLE_CACHE_VARIABLES})
            endif()
            if (DEPENDENCY_METHOD STREQUAL "FETCH_GIT")
                FetchContent_Declare(
                    ${DEPENDENCY}
                    GIT_REPOSITORY ${DEPENDENCY_GIT_REPOSITORY}
                    GIT_TAG        ${DEPENDENCY_GIT_TAG}
                    SOURCE_SUBDIR  ${DEPENDENCY_SOURCE_SUBDIR}
                    OVERRIDE_FIND_PACKAGE
                )
            elseif(DEPENDENCY_METHOD STREQUAL "FETCH_URL")
                set(URL_HASH_IF_AVAILABLE)
                if (DEPENDENCY_URL_HASH)
                    set(URL_HASH_IF_AVAILABLE URL_HASH "${DEPENDENCY_URL_HASH}")
                endif()
                FetchContent_Declare(
                    ${DEPENDENCY}
                    URL ${DEPENDENCY_URL}
                    ${URL_HASH_IF_AVAILABLE}
                    SOURCE_SUBDIR  ${DEPENDENCY_SOURCE_SUBDIR}
                    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
                    OVERRIDE_FIND_PACKAGE
                )
            else()
                message(FATAL_ERROR "METHOD ${DEPENDENCY_METHOD}")
            endif()
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
            message(STATUS "Fetched ${DEPENDENCY} to ${${DEPENDENCY_LOWERCASE}_SOURCE_DIR}.")
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
include(Dependencies/foxglove)
include(Dependencies/lz4)
include(Dependencies/manif)
include(Dependencies/nlohmann_json_schema_validator)
include(Dependencies/nlohmann_json)
include(Dependencies/mcap)
include(Dependencies/pinocchio)
include(Dependencies/zstd)
