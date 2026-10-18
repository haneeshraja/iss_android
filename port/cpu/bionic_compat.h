// Bionic compatibility header, force-included into the C++ units of the FEX build through
// cpu/fex_project.cmake.
//
// The pinned FEX commit calls getdents64 (Linux-specific) directly in FileUtils.cpp. glibc declares
// it under _LARGEFILE64_SOURCE and exports the symbol; Bionic's libc neither declares nor exports
// it (only the kernel syscall __NR_getdents64 exists). This provides an equivalent through
// syscall(2) so FEX's directory walking compiles and links on Bionic. Everything is C++ only:
// -include reaches every translation unit, and C/assembly units must not see any declaration.
#pragma once

#if defined(__cplusplus) && defined(__ANDROID__) && !defined(_WIN32)
#include <dirent.h>
#include <sys/syscall.h>
#include <sys/types.h>
#include <unistd.h>

extern "C" {

// Bionic has no getdents64 wrapper: use the raw syscall. The layout matches the kernel's
// struct linux_dirent64 (ino64, d_off, d_reclen, d_type, d_name).
inline ssize_t tlg_getdents64_wrap(int fd, void* dirp, size_t count) {
    return syscall(__NR_getdents64, fd, dirp, count);
}

}

#define getdents64 tlg_getdents64_wrap
#endif
