# CMake Includes
include(FetchContent)

# Ensure directory is on CMAKE_MODULE_PATH for cmake files within cmakebox
list(FIND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}" CMAKEBOX_ON_MODULE_PATH)
if (CMAKEBOX_ON_MODULE_PATH EQUAL -1)
    list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}")
endif()
unset(CMAKEBOX_ON_MODULE_PATH)

# Print CMake variables. Optionally pass a regex argument and only variable names matching that regex will be printed.
function(print_cmake_variables)
    get_cmake_property(VARIABLE_NAMES VARIABLES)
    list(SORT VARIABLE_NAMES)
    foreach (VARIABLE_NAME ${VARIABLE_NAMES})
        if (NOT DEFINED ARGV0 OR VARIABLE_NAME MATCHES ${ARGV0})
            message(STATUS "${VARIABLE_NAME}=${${VARIABLE_NAME}}")
        endif()
    endforeach()
endfunction()

# Create CMAKE_BUILD_TYPE option with default value and supported options
function(setup_build_type)
    if (NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
        set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Build Type" FORCE)
        set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "RelWithDebInfo" "MinSizeRel")
        message(STATUS "Build type set to ${CMAKE_BUILD_TYPE}")
    endif()
    set(RELEASE_BUILD_TYPES Release RelWithDebInfo MinSizeRel)
    if (NOT ${CMAKE_BUILD_TYPE} IN_LIST RELEASE_BUILD_TYPES)
        message(AUTHOR_WARNING "Non-Release build type ${CMAKE_BUILD_TYPE} is recommended only for debugging. "
                s"Prefer one of ${RELEASE_BUILD_TYPES}.")
    endif()
endfunction()

# Get information about the CXX Compiler and set CMAKE_CXX_COMPILER_VERSION_MAJOR and CMAKE_CXX_COMPILER_VERSION_MINOR
# variables.
function(get_cxx_compiler_info)
    if (NOT DEFINED CMAKE_CXX_COMPILER_VERSION_MAJOR OR NOT DEFINED CMAKE_CXX_COMPILER_VERSION_MINOR)
        message(STATUS "Detected ${CMAKE_CXX_COMPILER_ID} CXX compiler version ${CMAKE_CXX_COMPILER_VERSION}")
        string(REPLACE "." ";" CMAKE_CXX_COMPILER_VERSION_LIST ${CMAKE_CXX_COMPILER_VERSION})
        list(GET CMAKE_CXX_COMPILER_VERSION_LIST 0 _CMAKE_CXX_COMPILER_VERSION_MAJOR)
        list(GET CMAKE_CXX_COMPILER_VERSION_LIST 1 _CMAKE_CXX_COMPILER_VERSION_MINOR)
        set(CMAKE_CXX_COMPILER_VERSION_MAJOR ${_CMAKE_CXX_COMPILER_VERSION_MAJOR} PARENT_SCOPE)
        set(CMAKE_CXX_COMPILER_VERSION_MINOR ${_CMAKE_CXX_COMPILER_VERSION_MINOR} PARENT_SCOPE)
    endif()
endfunction()

# Create uninstall target (if doesn't exist and project is top level)
function(create_uninstall_target)
    if (PROJECT_IS_TOP_LEVEL)
        if (NOT TARGET uninstall)
            configure_file(
                "${CMAKE_CURRENT_LIST_DIR}/cmake_uninstall.cmake.in"
                "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake"
                @ONLY
            )
            add_custom_target(uninstall COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake)
        else()
            message(AUTHOR_WARNING "Skipping creation of uninstall target even though ${PROJECT_NAME} is top level "
                "project because target already exists (possibly created by an imported dependency).")
        endif()
    else()
        message(STATUS "Skipping creation of uninstall target because ${PROJECT_NAME} is not top level project.")
    endif()
endfunction()

# Enable each  BOOLvariable passed to this function, and cache the previous value for restoration.
function(enable_cache_variables)
    foreach(VARIABLE IN LISTS ARGN)
        if (DEFINED ${VARIABLE})
            set(CACHED_${VARIABLE} ${${VARIABLE}} PARENT_SCOPE)
        endif()
        set(${VARIABLE} ON CACHE BOOL "" FORCE)
    endforeach()
endfunction()

# Disable each BOOL variable passed to this function, and cache the previous value for restoration.
function(disable_cache_variables)
    foreach(VARIABLE IN LISTS ARGN)
        if (DEFINED ${VARIABLE})
            set(CACHED_${VARIABLE} ${${VARIABLE}} PARENT_SCOPE)
        endif()
        set(${VARIABLE} OFF CACHE BOOL "" FORCE)
    endforeach()
endfunction()

# Restore each BOOL variable passed to this function with its cached version (if it exists). This function is intended
# to be used in conjunction with enable_cache_variables and disable_cache_variables.
function(restore_cache_variables)
    foreach(VARIABLE IN LISTS ARGN)
        if (DEFINED CACHED_${VARIABLE})
            set(${VARIABLE} ${CACHED_${VARIABLE}} CACHE BOOL "" FORCE)
            unset(CACHED_${VARIABLE} PARENT_SCOPE)
        endif()
    endforeach()
endfunction()

# Import Dependency as:
#   import_dependency(
#        <dependency_name>
#        TARGET <STRING:target>
#        VERSION <STRING:version>
#        USE_SYSTEM_REQUIRED_VERSION <STRING:version>
#        GIT_REPOSITORY <STRING:repository>
#        GIT_TAG <STRING:tag/branch/commit>
#        [USE_SYSTEM]
#        [DISABLE_CACHE_VARS <VAR1> [<VAR2> ...]]
#        [ENABLE_CACHE_VARS <VAR1> [<VAR2> ...]]
#   )
function(import_dependency DEPENDENCY)
    set(OPTIONS
        USE_SYSTEM
    )
    set(SINGLE_VALUE_ARGS
        TARGET
        VERSION
        USE_SYSTEM_REQUIRED_VERSION
        GIT_REPOSITORY
        GIT_TAG
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
    string(TOUPPER ${DEPENDENCY} DEPENDENCY_UPPERCASE)

    if (NOT DEPENDENCY_TARGET)
        message(FATAL_ERROR "Missing argument TARGET for import_dependency ${DEPENDENCY}")
    endif()

    if (DEPENDENCY_USE_SYSTEM_REQUIRED_VERSION AND NOT DEPENDENCY_USE_SYSTEM
            AND DEPENDENCY_VERSION VERSION_LESS DEPENDENCY_USE_SYSTEM_REQUIRED_VERSION)
        message(FATAL_ERROR "Must use USE_SYSTEM flag for ${DEPENDENCY} VERSION < "
            "${DEPENDENCY_USE_SYSTEM_REQUIRED_VERSION}. ${DEPENDENCY} does not support FetchContent prior to this "
            "release. Requested VERSION was ${DEPENDENCY_VERSION}.")
    endif()

    if (NOT TARGET ${DEPENDENCY_TARGET})
        message(STATUS "Importing ${DEPENDENCY} (Target: ${DEPENDENCY_TARGET}, USE_SYSTEM = ${DEPENDENCY_USE_SYSTEM})")
        if (DEPENDENCY_USE_SYSTEM)
            message(STATUS "    VERSION=${DEPENDENCY_VERSION}")
            if (DEPENDENCY_USE_SYSTEM_REQUIRED_VERSION)
                message(DEBUG "    USE_SYSTEM_REQUIRED_VERSION=${DEPENDENCY_USE_SYSTEM_REQUIRED_VERSION}")
            endif()
        else()
            if (FETCHCONTENT_SOURCE_DIR_${DEPENDENCY_UPPERCASE})
                message(STATUS "    FETCHCONTENT_SOURCE_DIR=${FETCHCONTENT_SOURCE_DIR_${DEPENDENCY_UPPERCASE}}")
            else()
                message(STATUS "    GIT_REPOSITORY=${DEPENDENCY_GIT_REPOSITORY}")
                message(STATUS "    GIT_TAG=${DEPENDENCY_GIT_TAG}")
            endif()
            message(DEBUG "    DISABLE_CACHE_VARIABLES=${DEPENDENCY_DISABLE_CACHE_VARIABLES}")
            message(DEBUG "    ENABLE_CACHE_VARIABLES=${DEPENDENCY_ENABLE_CACHE_VARIABLES}")
        endif()

        if (DEPENDENCY_USE_SYSTEM)
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
            )
            if (FETCHCONTENT_SOURCE_DIR_${DEPENDENCY_UPPERCASE} AND NOT EXISTS
                    ${FETCHCONTENT_SOURCE_DIR_${DEPENDENCY_UPPERCASE}})
                message(FATAL_ERROR "FETCHCONTENT_SOURCE_DIR_${DEPENDENCY_UPPERCASE} was specified as "
                    "${FETCHCONTENT_SOURCE_DIR_${DEPENDENCY_UPPERCASE}} but no directory was found. The user is "
                    "resposible for downloading code to a specified FETCHCONTENT_SOURCE_DIR_${DEPENDENCY_UPPERCASE}.")
            endif()
            FetchContent_MakeAvailable(${DEPENDENCY})
            set(${DEPENDENCY}_DIR ${${DEPENDENCY}_BINARY_DIR} CACHE STRING "${DEPENDENCY} directory" FORCE)
            message(STATUS "Fetched ${DEPENDENCY} to ${${DEPENDENCY}_SOURCE_DIR} with tag ${DEPENDENCY_GIT_TAG}")
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
