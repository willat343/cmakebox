# Import foxglove as:
#   import_foxglove(
#        VERSION <STRING:version>
#        [METHOD <STRING:FETCH_GIT|FETCH_URL>]
#        [USE_SHARED_LIBRARY]
#   )
#
# Tested VERSIONs: 0.10.1
#
# Default METHOD is FETCH_URL.
#
# Swap from shared library to static library with USE_SHARED_LIBRARY option.
#
# If installing/exporting, then ${foxglove_REAL_TARGET} must be included in the install targets, for example:
#   `install(TARGET ... ${foxglove_REAL_TARGET} EXPORT ...)`
#
# Link to foxglove target with:
#   target_link_libraries(<target> <INTERFACE|PUBLIC|PRIVATE> foxglove::foxglove)
function(import_foxglove)
    set(OPTIONS
        USE_SHARED_LIBRARY
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
        set(DEPENDENCY_METHOD "FETCH_URL")
    endif()

    set(URL_HASH)
    if (DEPENDENCY_METHOD STREQUAL "FETCH_URL")
        if (DEPENDENCY_VERSION VERSION_EQUAL "0.7.1")
            set(URL_HASH "SHA256=2f942f3cefe27ee3de9bdb67df28a84042327103fe9733bd84b123de424a17a2")
        elseif(DEPENDENCY_VERSION VERSION_EQUAL "0.8.0")
            set(URL_HASH "SHA256=e539303b0db420638ae7d627a3d85df59a525078960a713c736b2728bba59e3c")
        elseif(DEPENDENCY_VERSION VERSION_EQUAL "0.8.1")
            set(URL_HASH "SHA256=d7a403435f543a6c5a8fbe431a72924152fc7f791c8e8e3e6cce4b2fd82ae467")
        elseif(DEPENDENCY_VERSION VERSION_EQUAL "0.9.0")
            set(URL_HASH "SHA256=48ea17c348583154d7c1934c9f7e82f57067e2afa76b586e1f7ac14cc6b6c1d0")
        elseif(DEPENDENCY_VERSION VERSION_EQUAL "0.9.1")
            set(URL_HASH "SHA256=7a9463270fac3cdf99ca5d41e597cae41e2c8b59a48b9eafec7a9ad6a70b11b1")
        elseif(DEPENDENCY_VERSION VERSION_EQUAL "0.10.0")
            set(URL_HASH "SHA256=209d34a8703d44a129c559493e1a3fb215888b4d5973622750ac28b1c345946c")
        elseif(DEPENDENCY_VERSION VERSION_EQUAL "0.10.1")
            set(URL_HASH "SHA256=099b022d1e911fbb7af1b1a85ced5234b10c7de753b24d402afcb595bc3add01")
        else()
            message(AUTHOR_WARNING "import_foxglove: Could not get URL_HASH for METHOD ${DEPENDENCY_METHOD}. "
                "Either the specified VERSION ${DEPENDENCY_VERSION} was incorrect or import_foxglove's URL_HASH"
                "database needs to be updated to contain the hash of this VERSION.")
        endif()
    endif()
    
    import_dependency(
        foxglove
        TARGET foxglove::foxglove
        METHOD ${DEPENDENCY_METHOD}
        FIND_PACKAGE_VERSION ${DEPENDENCY_VERSION}
        GIT_REPOSITORY https://github.com/foxglove/foxglove-sdk.git
        GIT_TAG sdk/v${DEPENDENCY_VERSION}
        SOURCE_SUBDIR cpp
        URL https://github.com/foxglove/foxglove-sdk/releases/download/sdk/v${DEPENDENCY_VERSION}/foxglove-v${DEPENDENCY_VERSION}-cpp-x86_64-unknown-linux-gnu.zip
        URL_HASH ${URL_HASH}
    )
    if (NOT foxglove_SOURCE_DIR)
        FetchContent_GetProperties(foxglove SOURCE_DIR foxglove_SOURCE_DIR)
    endif()

    if (NOT TARGET foxglove::foxglove)  
        set(foxglove_REAL_TARGET foxglove_cpp_static CACHE STRING "foxglove real target for install/export" FORCE)
        if (DEPENDENCY_USE_SHARED_LIBRARY)
            set(foxglove_REAL_TARGET foxglove_cpp_shared CACHE STRING "foxglove real target for install/export" FORCE)
        endif()
        if (DEPENDENCY_METHOD STREQUAL "FETCH_GIT")
            add_library(foxglove::foxglove ALIAS ${foxglove_REAL_TARGET})
        elseif (DEPENDENCY_METHOD STREQUAL "FETCH_URL")
            set(foxglove_LIBRARY_TYPE STATIC)
            if (DEPENDENCY_USE_SHARED_LIBRARY)
                set(foxglove_LIBRARY_TYPE SHARED)
            endif()
            set(foxglove_LIBRARY_FILE libfoxglove.a)
            if (DEPENDENCY_USE_SHARED_LIBRARY)
                set(foxglove_LIBRARY_FILE libfoxglove.so)
            endif()
            include(GNUInstallDirs)
            file(GLOB foxglove_SRC_FILES CONFIGURE_DEPENDS
                "${foxglove_SOURCE_DIR}/src/*.cpp"
                "${foxglove_SOURCE_DIR}/src/server/*.cpp"
            )
            add_library(${foxglove_REAL_TARGET} ${foxglove_LIBRARY_TYPE}
                ${foxglove_SRC_FILES}
            )
            add_library(foxglove::foxglove ALIAS ${foxglove_REAL_TARGET})
            target_include_directories(${foxglove_REAL_TARGET} PUBLIC
                $<BUILD_INTERFACE:${foxglove_SOURCE_DIR}/include>
                $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
            )
            set_target_properties(${foxglove_REAL_TARGET} PROPERTIES
                CXX_STANDARD 17
                CXX_STANDARD_REQUIRED ON
            )
            target_link_libraries(${foxglove_REAL_TARGET} PRIVATE
                "${foxglove_SOURCE_DIR}/lib/${foxglove_LIBRARY_FILE}"
                dl
                pthread
            )
            install(
                DIRECTORY include/foxglove
                DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
                FILES_MATCHING
                    PATTERN "*.hpp"
                    PATTERN "*.h"
            )
        endif()
    endif()

endfunction()
