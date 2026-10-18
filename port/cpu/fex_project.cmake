# Included by FEX's project() (CMAKE_PROJECT_FEX_INCLUDE, see tools/android/build_bionic.sh).
# FEX's CMake files expect to be the top-level project, so libtlgcpu is added to FEX's build once
# all of its targets exist. EVAL expands the path now; deferred arguments are expanded when the
# call runs.
cmake_language(EVAL CODE "cmake_language(DEFER DIRECTORY \"${CMAKE_SOURCE_DIR}\" CALL include \"${CMAKE_CURRENT_LIST_DIR}/tlgcpu.cmake\")")

# Bionic (Android NDK) build: FEX's CMake only knows Linux and Windows. Android is Linux on the
# kernel side; the toolchain file's ANDROID variable is kept for the places that need to tell them
# apart.
if(ANDROID AND CMAKE_SYSTEM_NAME STREQUAL "Android")
  set(CMAKE_SYSTEM_NAME Linux)
  # FEX walks directories with getdents64 (FileUtils.cpp). glibc declares it by default; Bionic
  # neither declares nor exports it (only the kernel syscall __NR_getdents64 exists), so
  # cpu/bionic_compat.h supplies a syscall wrapper.
  add_compile_definitions(_GNU_SOURCE)
  add_compile_options("-include" "${CMAKE_CURRENT_LIST_DIR}/bionic_compat.h")
endif()
