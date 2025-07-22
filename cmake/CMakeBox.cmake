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

include(CMakeBoxDependencies)
