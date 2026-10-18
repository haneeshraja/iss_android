# Android (arm64) port: status and plan

**Status: not started in code. Nothing here has been built or run on a device.**
Target device: Retroid Pocket 6 (Snapdragon 8 Gen 2, Adreno 740).

This fork of [HayatoG/iss_pc](https://github.com/HayatoG/iss_pc) aims to run inFAMOUS Second Son on
arm64 Android the way [zFitness/gow3_android](https://github.com/zFitness/gow3_android) runs God of
War III: the game's x86-64 code is translated by FEXCore, the PS4 runtime and the shadPS4-based GPU
core are built for Bionic/arm64, graphics go through the Turnip Vulkan driver, and a Kotlin launcher
manages the process. Both projects are GPL-2.0; keep their credits.

No game files are included. You need your own dump (CUSA00223, base 1.00 + update 1.07, about 33 GB).

## What gow3_android adds on top of its desktop port

| Piece | Where in gow3_android | Needed here |
| --- | --- | --- |
| CPU boundary (`guest_cpu.h`, `runtime_cpu.c`) | `src/` | yes, thread through `port/src/probe.c` and the thread, memory and freeze runtime files |
| FEXCore JIT layer | `cpu/` | yes, copy and rename |
| Android window / driver loader / present client | `gpu/shim/` | yes |
| Bionic build scripts | `tools/android/` | yes, adapt |
| Kotlin/Compose launcher | `android-launcher/` | yes, rename and adapt for inFAMOUS |
| CI that builds the APK | `.github/workflows/android.yml` | yes, change to a debug signing key |

## Known blockers specific to inFAMOUS

1. **ISA rewrite.** `port/src/isa_rewrite.c` patches the game's SSE4A (96 sites), F16C, MOVBE, BMI1
   and LZCNT instructions with x86 stubs, and some sites use `int3` traps handled in `probe.c`
   through x86 `ucontext` registers. An arm64 host has no equivalent. The stubs call host functions,
   which under FEX must be wrapped with `guest_cpu_host_function`, and trap sites would have to move
   to `guest_cpu_hook`. It is not known whether FEX decodes SSE4A itself, which would make the
   rewrite unnecessary. This must be checked first on a device.
2. **x86-only host code in `probe.c`**: inline `fldcw`, `enter_on_stack`, `REG_RIP` access.
3. **Performance.** The desktop port runs at 20-30 FPS on an RTX 2060 and is called unstable. Expect
   much lower under FEX on a handheld.

## Build loop

CI builds the APK (the sandbox used to write this has no Android SDK/NDK). Install the APK, copy the
game folder to the device, run, and send the log back.
