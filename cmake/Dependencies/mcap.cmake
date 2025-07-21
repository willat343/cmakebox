# Import mcap as:
#   import_mcap(
#        VERSION <STRING:version>
#   )
#
# Link to mcap target with:
#   target_link_libraries(<target> <INTERFACE|PUBLIC|PRIVATE> mcap::mcap)
function(import_mcap)
    set(OPTIONS)
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
        mcap_cpp
        TARGET mcap::mcap
        VERSION ${DEPENDENCY_VERSION}
        GIT_REPOSITORY https://github.com/foxglove/mcap.git
        GIT_TAG releases/cpp/v${DEPENDENCY_VERSION}
        ${OUTPUT_OPTIONS}
    )
    FetchContent_GetProperties(mcap_cpp SOURCE_DIR mcap_cpp_SOURCE_DIR)

    # TODO: use insights from https://github.com/olympus-robotics/mcap_builder to improve this
    add_library(mcap INTERFACE)
    add_library(mcap::mcap ALIAS mcap)
    target_include_directories(mcap INTERFACE ${mcap_cpp_SOURCE_DIR}/cpp/mcap/include)
    target_compile_definitions(mcap INTERFACE
        MCAP_IMPLEMENTATION
        MCAP_COMPRESSION_NO_LZ4     # TODO: add option to import lz4
        MCAP_COMPRESSION_NO_ZSTD    # TODO: add option to import zstd
    )
endfunction()
