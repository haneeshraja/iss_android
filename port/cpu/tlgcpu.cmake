# libtlgcpu.so: guest_cpu.h on FEXCore, linked statically against FEX's libraries.
set(TLGCPU_DIR "${CMAKE_CURRENT_LIST_DIR}")
add_library(tlgcpu SHARED "${TLGCPU_DIR}/guest_cpu_fex.cpp" "${TLGCPU_DIR}/host_call_arm64.S")
target_include_directories(tlgcpu PRIVATE "${TLGCPU_DIR}/../src" "${CMAKE_SOURCE_DIR}/Source" "${CMAKE_BINARY_DIR}/generated")
target_link_libraries(tlgcpu PRIVATE FEXCore Common JemallocLibs fmt::fmt)
target_link_options(tlgcpu PRIVATE -Wl,--no-undefined)
target_compile_options(tlgcpu PRIVATE ${FEX_TUNE_COMPILE_FLAGS})
set_target_properties(tlgcpu PROPERTIES
  LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}"
  C_VISIBILITY_PRESET hidden
  CXX_VISIBILITY_PRESET hidden
  VISIBILITY_INLINES_HIDDEN TRUE)

if(ANDROID)
  # libc++ (the only C++ library on Bionic) does not satisfy fextl::move_only_function's need to
  # assign a noexcept std::function, which FEXServerClient.cpp relies on. This library does not run
  # FEXServer, so that file is removed from FEX's Common target; the link step will say whether
  # anything else still needs it.
  get_target_property(tlg_common_sources Common SOURCES)
  list(FILTER tlg_common_sources EXCLUDE REGEX "FEXServerClient\\.cpp$")
  set_target_properties(Common PROPERTIES SOURCES "${tlg_common_sources}")
endif()
