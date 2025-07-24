# cmakebox

Collection of general-purpose CMake functions and utilities

## Include cmakebox in your project

Include in your CMake project (replace `X.Y.Z` with required version):
```CMake
# Dependency: cmakebox
set(CMAKEBOX_VERSION "X.Y.Z")
FetchContent_Declare(
    cmakebox
    GIT_REPOSITORY git@github.com:willat343/cmakebox.git
    GIT_TAG v${CMAKEBOX_VERSION}
)
FetchContent_MakeAvailable(cmakebox)
list(APPEND CMAKE_MODULE_PATH "${cmakebox_SOURCE_DIR}/cmake")
include(CMakeBox)
```

This provides several useful CMake functions for your project.

## Import dependencies

One of the most important functions provided by cmakebox is `import_dependency()`.

Additionally several `import_*()` functions are provided for importing specific dependencies.


