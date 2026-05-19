# Import Boost as:
#   import_Boost(
#        VERSION <STRING:version>
#        [METHOD <STRING:FETCH_URL>]
#        [BOOST_REQUIRED_LIBRARIES <VAR1> [<VAR2> ...]]
#   )
#
# Tested VERSIONs: 1.90.0
#
# Default METHOD is FETCH_URL. FETCH_GIT is not recommended due to how huge boost is.
#
# BOOST_REQUIRED_LIBRARIES should be set to the required libraries, e.g. asio core filesystem headers serialization. 
#
# Link to one of the boost targets (Boost::headers, Boost::core, Boost::system, Boost::filesystem, ...) with:
#   target_link_libraries(<target> <INTERFACE|PUBLIC|PRIVATE> Boost::headers ...)
function(import_Boost)
    set(OPTIONS)
    set(SINGLE_VALUE_ARGS
        VERSION
        METHOD
    )
    set(MULTI_VALUE_ARGS
        BOOST_INCLUDE_LIBRARIES
    )
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

    if (NOT DEPENDENCY_USE_FIND_PACKAGE AND DEPENDENCY_VERSION VERSION_LESS "1.81.0")
        message(FATAL_ERROR "FetchContent not supported prior to version 1.81.0.")
    endif()

    if (NOT DEPENDENCY_BOOST_INCLUDE_LIBRARIES)
        set(DEPENDENCY_BOOST_INCLUDE_LIBRARIES headers)
    endif()

    set(URL)
    if (DEPENDENCY_METHOD STREQUAL "FETCH_URL")
        if (DEPENDENCY_VERSION VERSION_LESS "1.85.0")
            set(URL https://github.com/boostorg/boost/releases/download/boost-${DEPENDENCY_VERSION}/boost-${DEPENDENCY_VERSION}.tar.xz)
        else()
            set(URL https://github.com/boostorg/boost/releases/download/boost-${DEPENDENCY_VERSION}/boost-${DEPENDENCY_VERSION}-cmake.tar.xz)
        endif()
    endif()

    set(URL_HASH)
    if (DEPENDENCY_METHOD STREQUAL "FETCH_URL")
        if(DEPENDENCY_VERSION VERSION_EQUAL "1.81.0")
            set(URL_HASH "SHA256=06bc525a392650eb6248f40a13f40112b6c485eec7103b6dcde7196f2a3570e0")
        elseif(DEPENDENCY_VERSION VERSION_EQUAL "1.82.0")
            set(URL_HASH "SHA256=fd60da30be908eff945735ac7d4d9addc7f7725b1ff6fcdcaede5262d511d21e")
        elseif(DEPENDENCY_VERSION VERSION_EQUAL "1.83.0")
            set(URL_HASH "SHA256=c5a0688e1f0c05f354bbd0b32244d36085d9ffc9f932e8a18983a9908096f614")
        elseif(DEPENDENCY_VERSION VERSION_EQUAL "1.84.0")
            set(URL_HASH "SHA256=2e64e5d79a738d0fa6fb546c6e5c2bd28f88d268a2a080546f74e5ff98f29d0e")
        elseif(DEPENDENCY_VERSION VERSION_EQUAL "1.85.0")
            set(URL_HASH "SHA256=0a9cc56ceae46986f5f4d43fe0311d90cf6d2fa9028258a95cab49ffdacf92ad")
        elseif(DEPENDENCY_VERSION VERSION_EQUAL "1.86.0")
            set(URL_HASH "SHA256=2c5ec5edcdff47ff55e27ed9560b0a0b94b07bd07ed9928b476150e16b0efc57")
        elseif(DEPENDENCY_VERSION VERSION_EQUAL "1.87.0")
            set(URL_HASH "SHA256=7da75f171837577a52bbf217e17f8ea576c7c246e4594d617bfde7fafd408be5")
        elseif(DEPENDENCY_VERSION VERSION_EQUAL "1.88.0")
            set(URL_HASH "SHA256=f48b48390380cfb94a629872346e3a81370dc498896f16019ade727ab72eb1ec")
        elseif(DEPENDENCY_VERSION VERSION_EQUAL "1.89.0")
            set(URL_HASH "SHA256=67acec02d0d118b5de9eb441f5fb707b3a1cdd884be00ca24b9a73c995511f74")
        elseif(DEPENDENCY_VERSION VERSION_EQUAL "1.90.0")
            set(URL_HASH "SHA256=aca59f889f0f32028ad88ba6764582b63c916ce5f77b31289ad19421a96c555f")
        else()
            message(AUTHOR_WARNING "import_Boost: Could not get URL_HASH for METHOD ${DEPENDENCY_METHOD}. "
                "Either the specified VERSION ${DEPENDENCY_VERSION} was incorrect or import_Boost's URL_HASH"
                "database needs to be updated to contain the hash of this VERSION.")
        endif()
    endif()

    # For now restrict to just the headers library/target
    set(BOOST_INCLUDE_LIBRARIES ${DEPENDENCY_BOOST_INCLUDE_LIBRARIES} CACHE STRING "Boost libraries to include" FORCE)

    import_dependency(
        Boost
        TARGET Boost::headers
        METHOD ${DEPENDENCY_METHOD}
        FIND_PACKAGE_VERSION ${DEPENDENCY_VERSION}
        GIT_REPOSITORY https://github.com/boostorg/boost
        GIT_TAG boost-${DEPENDENCY_VERSION}
        URL ${URL}
        URL_HASH ${URL_HASH}
        ENABLE_CACHE_VARIABLES BOOST_ENABLE_CMAKE
        DISABLE_CACHE_VARIABLES BUILD_TESTING BUILD_EXAMPLES
    )
endfunction()
