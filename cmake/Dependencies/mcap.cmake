# Import mcap as:
#   import_mcap(
#        VERSION <STRING:version>
#        [METHOD <STRING:FETCH_GIT>]
#        [IMPORT_LZ4]
#        [IMPORT_ZSTD]
#   )
#
# Default METHOD is FETCH_GIT.
#
# Link to mcap target with:
#   target_link_libraries(<target> <INTERFACE|PUBLIC|PRIVATE> mcap::mcap)
function(import_mcap)
    set(OPTIONS
        IMPORT_LZ4
        IMPORT_ZSTD
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

    if (DEPENDENCY_IMPORT_LZ4)
        import_lz4(
            VERSION 1.10.0
        )
    endif()

    if (DEPENDENCY_IMPORT_ZSTD)
        import_zstd(
            VERSION 1.5.7
        )
    endif()

    if (NOT DEPENDENCY_METHOD)
        set(DEPENDENCY_METHOD "FETCH_GIT")
    endif()

    set(MCAP_LINK_LIBRARIES)
    set(MCAP_COMPILE_DEFINITIONS MCAP_IMPLEMENTATION)
    if (TARGET LZ4::lz4)
        list(APPEND MCAP_LINK_LIBRARIES LZ4::lz4)
    else()
        list(APPEND MCAP_COMPILE_DEFINITIONS MCAP_COMPRESSION_NO_LZ4)
    endif()
    if (TARGET zstd::libzstd)
        list(APPEND MCAP_LINK_LIBRARIES zstd::libzstd)
    else()
        list(APPEND MCAP_COMPILE_DEFINITIONS MCAP_COMPRESSION_NO_ZSTD)
    endif()

    import_dependency(
        mcap_cpp
        TARGET mcap::mcap
        METHOD ${DEPENDENCY_METHOD}
        FIND_PACKAGE_VERSION ${DEPENDENCY_VERSION}
        GIT_REPOSITORY https://github.com/foxglove/mcap.git
        GIT_TAG releases/cpp/v${DEPENDENCY_VERSION}
    )
    FetchContent_GetProperties(mcap_cpp SOURCE_DIR mcap_cpp_SOURCE_DIR)

    # TODO: use install/export insights from https://github.com/olympus-robotics/mcap_builder
    if (NOT TARGET mcap::mcap)
        add_library(mcap INTERFACE)
        add_library(mcap::mcap ALIAS mcap)
        if (MCAP_LINK_LIBRARIES)
            target_link_libraries(mcap INTERFACE ${MCAP_LINK_LIBRARIES})
        endif()
        target_include_directories(mcap INTERFACE ${mcap_cpp_SOURCE_DIR}/cpp/mcap/include)
        target_compile_definitions(mcap INTERFACE ${MCAP_COMPILE_DEFINITIONS})
    endif()
endfunction()
