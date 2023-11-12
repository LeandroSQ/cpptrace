# Included further down to avoid interfering with our cache variables
# include(GNUInstallDirs)

# ---- Options Summary ----

# ---------------------------------------------------------------------------------------------------
# | Option                          | Availability  | Default                                       |
# |=================================|===============|===============================================|
# | BUILD_SHARED_LIBS               | Top-Level     | OFF                                           |
# | BUILD_TESTING                   | Top-Level     | OFF                                           |
# | CMAKE_INSTALL_INCLUDEDIR        | Top-Level     | include/${package_name}-${PROJECT_VERSION}    |
# |---------------------------------|---------------|-----------------------------------------------|
# | CPPTRACE_BUILD_SHARED           | Always        | ${BUILD_SHARED_LIBS}                          |
# | CPPTRACE_BUILD_TESTING          | Always        | ${BUILD_TESTING} AND ${PROJECT_IS_TOP_LEVEL}  |
# | CPPTRACE_INCLUDES_WITH_SYSTEM   | Not Top-Level | ON                                            |
# | CPPTRACE_INSTALL_CMAKEDIR       | Always        | ${CMAKE_INSTALL_LIBDIR}/cmake/${package_name} |
# | CPPTRACE_USE_EXTERNAL_LIBDWARF  | Always        | OFF                                           |
# | ...                             |               |                                               |
# ---------------------------------------------------------------------------------------------------

# ---- Build Shared ----

# Sometimes it's useful to be able to single out a dependency to be built as
# static or shared, even if obtained from source
if(PROJECT_IS_TOP_LEVEL)
  option(BUILD_SHARED_LIBS "Build shared libs" OFF)
endif()
option(
  CPPTRACE_BUILD_SHARED
  "Override BUILD_SHARED_LIBS for ${package_name} library"
  ${BUILD_SHARED_LIBS}
)
mark_as_advanced(CPPTRACE_BUILD_SHARED)
set(build_type STATIC)
if(CPPTRACE_BUILD_SHARED)
  set(build_type SHARED)
endif()

# ---- Warning Guard ----

# target_include_directories with SYSTEM modifier will request the compiler to
# omit warnings from the provided paths, if the compiler supports that.
# This is to provide a user experience similar to find_package when
# add_subdirectory or FetchContent is used to consume this project.
set(warning_guard )
if(NOT PROJECT_IS_TOP_LEVEL)
    option(
        CPPTRACE_INCLUDES_WITH_SYSTEM
        "Use SYSTEM modifier for ${package_name}'s includes, disabling warnings"
        ON
    )
    mark_as_advanced(CPPTRACE_INCLUDES_WITH_SYSTEM)
    if(CPPTRACE_INCLUDES_WITH_SYSTEM)
        set(warning_guard SYSTEM)
    endif()
endif()

# ---- Enable Testing ----

# By default tests aren't enabled even with BUILD_TESTING=ON unless the library
# is built as a top level project.
# This is in order to cut down on unnecessary compile times, since it's unlikely
# for users to want to run the tests of their dependencies.
if(PROJECT_IS_TOP_LEVEL)
  option(BUILD_TESTING "Build tests" OFF)
endif()
if(PROJECT_IS_TOP_LEVEL AND BUILD_TESTING)
  set(build_testing ON)
endif()
option(
  CPPTRACE_BUILD_TESTING
  "Override BUILD_TESTING for ${package_name} library"
  ${build_testing}
)
set(build_testing )
mark_as_advanced(CPPTRACE_BUILD_TESTING)

# ---- Install Include Directory ----

# Adds an extra directory to the include path by default, so that when you link
# against the target, you get `<prefix>/include/<package-X.Y.Z>` added to your
# include paths rather than `<prefix>/include`.
# This doesn't affect include paths used by consumers of this project, but helps
# prevent consumers having access to other projects in the same include
# directory (e.g. usr/include).
# The variable type is STRING rather than PATH, because otherwise passing
# -DCMAKE_INSTALL_INCLUDEDIR=include on the command line would expand to an
# absolute path with the base being the current CMake directory, leading to
# unexpected errors.
if(PROJECT_IS_TOP_LEVEL)
  set(
      CMAKE_INSTALL_INCLUDEDIR "include/${package_name}-${PROJECT_VERSION}"
      CACHE STRING ""
  )
  # marked as advanced in GNUInstallDirs version, so we follow their lead
  mark_as_advanced(CMAKE_INSTALL_INCLUDEDIR)
endif()

# do not include earlier or we can't set CMAKE_INSTALL_INCLUDEDIR above
# include required for CMAKE_INSTALL_LIBDIR below
include(GNUInstallDirs)

# ---- Install CMake Directory ----

# This allows package maintainers to freely override the installation path for
# the CMake configs.
# This doesn't affects include paths used by consumers of this project.
# The variable type is STRING rather than PATH, because otherwise passing
# -DCPPTRACE_INSTALL_CMAKEDIR=lib/cmake on the command line would expand to an
# absolute path with the base being the current CMake directory, leading to
# unexpected errors.
set(
  CPPTRACE_INSTALL_CMAKEDIR "${CMAKE_INSTALL_LIBDIR}/cmake/${package_name}"
  CACHE STRING "CMake package config location relative to the install prefix"
)
# depends on CMAKE_INSTALL_LIBDIR which is marked as advanced in GNUInstallDirs
mark_as_advanced(CPPTRACE_INSTALL_CMAKEDIR)

# ---- Symbol Options ----

option(CPPTRACE_GET_SYMBOLS_WITH_LIBBACKTRACE "" OFF)
option(CPPTRACE_GET_SYMBOLS_WITH_LIBDWARF "" OFF)
option(CPPTRACE_GET_SYMBOLS_WITH_LIBDL "" OFF)
option(CPPTRACE_GET_SYMBOLS_WITH_ADDR2LINE "" OFF)
option(CPPTRACE_GET_SYMBOLS_WITH_DBGHELP "" OFF)
option(CPPTRACE_GET_SYMBOLS_WITH_NOTHING "" OFF)

# ---- Unwinding Options ----

option(CPPTRACE_UNWIND_WITH_UNWIND "" OFF)
option(CPPTRACE_UNWIND_WITH_LIBUNWIND "" OFF)
option(CPPTRACE_UNWIND_WITH_EXECINFO "" OFF)
option(CPPTRACE_UNWIND_WITH_WINAPI "" OFF)
option(CPPTRACE_UNWIND_WITH_DBGHELP "" OFF)
option(CPPTRACE_UNWIND_WITH_NOTHING "" OFF)

# ---- Demangling Options ----

option(CPPTRACE_DEMANGLE_WITH_CXXABI "" OFF)
option(CPPTRACE_DEMANGLE_WITH_WINAPI "" OFF)
option(CPPTRACE_DEMANGLE_WITH_NOTHING "" OFF)

# ---- Back-end configurations ----

set(CPPTRACE_BACKTRACE_PATH "" CACHE STRING "Path to backtrace.h, if the compiler doesn't already know it. Check /usr/lib/gcc/x86_64-linux-gnu/*/include.")
set(CPPTRACE_HARD_MAX_FRAMES "" CACHE STRING "Hard limit on unwinding depth. Default is 100.")
set(CPPTRACE_ADDR2LINE_PATH "" CACHE STRING "Absolute path to the addr2line executable you want to use.")
option(CPPTRACE_ADDR2LINE_SEARCH_SYSTEM_PATH "" OFF)

# ---- Other configurations ----

if(PROJECT_IS_TOP_LEVEL)
  option(CPPTRACE_BUILD_TEST "" OFF)
  option(CPPTRACE_BUILD_DEMO "" OFF)
  option(CPPTRACE_BUILD_TEST_RDYNAMIC "" OFF)
  mark_as_advanced(
    CPPTRACE_BUILD_TEST
    CPPTRACE_BUILD_DEMO
    CPPTRACE_BUILD_TEST_RDYNAMIC
  )
endif()

option(CPPTRACE_USE_EXTERNAL_LIBDWARF "" OFF)
option(CPPTRACE_SANITIZER_BUILD "" OFF)

mark_as_advanced(
  CPPTRACE_BACKTRACE_PATH
  CPPTRACE_ADDR2LINE_PATH
  CPPTRACE_ADDR2LINE_SEARCH_SYSTEM_PATH
  CPPTRACE_SANITIZER_BUILD
)
