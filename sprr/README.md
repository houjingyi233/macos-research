### Undefined Behavior Fuzzing M1 Apple Silicon Register S3_6_c15_c1_5

On May 6, 2021 a Post by Sven Peter about Apple Silicon Hardware Secrets: SPRR and Guarded Exception Levels (GXF) at URL https://blog.svenpeter.dev/posts/m1_sprr_gxf/ appeared in my Timeline.

An interesting Read but no additional information was provided with respect to Fuzzing those 64 Register Bits, just performing a Bit Flip with the provided example SPRR JIT test code. My first thoughts were: What happens when the Program Counter is lightly Fuzzed? 
Example: pc += (i) ... for (int i = 0; i < 32; ++i)

Expected Results (Source: Sven Peter)
--------------------------------------
register value	page permissions
00	---
01	r-x
10	r--
11	rw-

Actual Results: 
cx->uc_mcontext->```__ss.__pc += (i) ... for (int i = 0; i < 256; ++i)``` 

Expected and Undefined behavior which is the Subject of this Post, see all Results below.

### M1 SPRR Profiling, Reporting and Build Info

Orignal Blog Post: https://blog.svenpeter.dev/posts/m1_sprr_gxf/
 
 Comments, Build, Profiling Instructions added by dhoyt | @h02332 on May 23, 2021
 UBSAN Report with Xcode Profiling Instructions

BUILD 
---------
```
clang -fprofile-instr-generate -fcoverage-mapping -mllvm -runtime-counter-relocation -g -fsanitize=undefined -O0 -o a.out code.c
 ```
PROFILE 
--------
```
LLVM_PROFILE_FILE=default.profraw ./a.out
xcrun llvm-profdata merge -sparse default.profraw -o a.profdata
xcrun llvm-cov show ./a.out -instr-profile=a.profdata
```
REPORT
--------
```
xcrun llvm-cov show ./a.out -instr-profile=a.profdata --show-regions=0 -show-line-counts-or-regions -show-instantiation-summary
xcrun llvm-cov report ./a.out -instr-profile=a.profdata
sudo gcovr --gcov-executable "xcrun llvm-cov gcov" -r . --html --html-details -o out.html

RUN
	LLVM_PROFILE_FILE=default.profraw ./a.out
```
LIGHT FUZZING - __ss.__pc =+ (i) .... for (int i = 0; i < 32; ++i)
====================
```
cx->uc_mcontext->__ss.__pc +=   + 1
2010000030000000: ---
2010000030100000: r-x
2010000030200000: r--
2010000030300000: rw-
cx->uc_mcontext->__ss.__pc +=   + 2
2010000030000000: ---
2010000030100000: r-x
2010000030200000: r--
2010000030300000: rw-
cx->uc_mcontext->__ss.__pc +=   + 3
2010000030000000: rw-
2010000030100000: rwx
2010000030200000: rw-
2010000030300000: rw-
cx->uc_mcontext->__ss.__pc +=   + 4
2010000030000000: ---
2010000030100000: r-x
2010000030200000: r--
2010000030300000: rw-
cx->uc_mcontext->__ss.__pc +=   + 5
2010000030000000: rw-
2010000030100000: rwx
2010000030200000: rw-
2010000030300000: rw-
cx->uc_mcontext->__ss.__pc +=   + 6
2010000030000000: rw-
2010000030100000: rwx
2010000030200000: rw-
2010000030300000: rw-
cx->uc_mcontext->__ss.__pc +=   + 7
2010000030000000: ---
2010000030100000: rwx
2010000030200000: rw-
2010000030300000: rw-
cx->uc_mcontext->__ss.__pc +=   + 8
2010000030000000: rw-
2010000030100000: rwx
2010000030200000: rw-
2010000030300000: rw-
cx->uc_mcontext->__ss.__pc +=   + 9
2010000030000000: ---
2010000030100000: r-x
2010000030200000: r--
2010000030300000: rw-
cx->uc_mcontext->__ss.__pc +=   + 10
2010000030000000: rw-
2010000030100000: rwx
2010000030200000: rw-
2010000030300000: rw-
cx->uc_mcontext->__ss.__pc +=   + 11
2010000030000000: ---
2010000030100000: rwx
2010000030200000: rw-
2010000030300000: rw-
cx->uc_mcontext->__ss.__pc +=   + 12
2010000030000000: rw-
2010000030100000: rwx
2010000030200000: rw-
2010000030300000: rw-
cx->uc_mcontext->__ss.__pc +=   + 13
2010000030000000: ---
2010000030100000: r-x
2010000030200000: r--
2010000030300000: rw-
cx->uc_mcontext->__ss.__pc +=   + 14
2010000030000000: ---
2010000030100000: rwx
2010000030200000: rw-
2010000030300000: rw-
cx->uc_mcontext->__ss.__pc +=   + 15
2010000030000000: ---
2010000030100000: rwx
2010000030200000: rw-
2010000030300000: rw-
cx->uc_mcontext->__ss.__pc +=   + 16
2010000030000000: rw-
2010000030100000: rwx
2010000030200000: rw-
2010000030300000: rw-
cx->uc_mcontext->__ss.__pc +=   + 17
2010000030000000: rw-
2010000030100000: rwx
2010000030200000: rw-
2010000030300000: rw-
cx->uc_mcontext->__ss.__pc +=   + 18
2010000030000000: ---
2010000030100000: r-x
2010000030200000: r--
2010000030300000: rw-
cx->uc_mcontext->__ss.__pc +=   + 19
2010000030000000: ?--
---HANG---
cx->uc_mcontext->__ss.__pc +=   + 20
2010000030000000: rw-
2010000030100000: rwx
2010000030200000: rw-
2010000030300000: rw-
cx->uc_mcontext->__ss.__pc +=   + 21
---HANG---
cx->uc_mcontext->__ss.__pc +=   + 22
2010000030000000: ---
2010000030100000: rwx
2010000030200000: rw-
2010000030300000: rw-
cx->uc_mcontext->__ss.__pc +=   + 23
---HANG---
cx->uc_mcontext->__ss.__pc +=   + 24
2010000030000000: -w-
2010000030100000: rwx
2010000030200000: rw-
2010000030300000: rw-
cx->uc_mcontext->__ss.__pc +=   + 25
---HANG---
cx->uc_mcontext->__ss.__pc +=   + 26
2010000030000000: ---
2010000030100000: r-x
2010000030200000: r--
2010000030300000: rw-
cx->uc_mcontext->__ss.__pc +=   + 27
2010000030000000: ---
2010000030100000: rwx
2010000030200000: rw-
2010000030300000: rw-
cx->uc_mcontext->__ss.__pc +=   + 28
2010000030000000: ---
2010000030100000: rwx
2010000030200000: rw-
2010000030300000: rw-
cx->uc_mcontext->__ss.__pc +=   + 29
---HANG---
cx->uc_mcontext->__ss.__pc +=   + 30
2010000030000000: ---
2010000030100000: rwx
2010000030200000: rw-
2010000030300000: rw-
cx->uc_mcontext->__ss.__pc +=   + 31
---HANG---
cx->uc_mcontext->__ss.__pc +=   + 32
2010000030000000: ---
2010000030100000: r-x
2010000030200000: r--
2010000030300000: rw-


cx->uc_mcontext->__ss.__pc +=   + 256
---HANG---
```

UNDEFINED BEHAVIOR SANITIZER OUTPUT - UBSAN
================================================
```
REPRO - SIP OFF, ALL M1 SECURITY OFF
LLVM_PROFILE_FILE=default.profraw ./a.out
...
code.c:25:9: runtime error: member access within misaligned address 0x00016d0471b8 for type 'ucontext_t' (aka 'struct __darwin_ucontext'), which requires 16 byte alignment
0x00016d0471b8: note: pointer points here
 00 00 00 00  00 00 00 00 00 00 00 00  50 71 04 6d 01 00 00 00  00 00 00 00 00 00 00 00  00 00 00 00
              ^ 
SUMMARY: UndefinedBehaviorSanitizer: undefined-behavior code.c:25:9 in 
code.c:25:9: runtime error: load of misaligned address 0x00016d0471e8 for type 'struct __darwin_mcontext64 *', which requires 16 byte alignment
0x00016d0471e8: note: pointer points here
 00 00 00 00  f0 71 04 6d 01 00 00 00  00 00 ea 02 01 00 00 00  0f 00 00 92 00 00 00 00  00 00 ea 02
              ^ 
SUMMARY: UndefinedBehaviorSanitizer: undefined-behavior code.c:25:9 in 
code.c:26:9: runtime error: member access within misaligned address 0x00016d0471b8 for type 'ucontext_t' (aka 'struct __darwin_ucontext'), which requires 16 byte alignment
0x00016d0471b8: note: pointer points here
 00 00 00 00  00 00 00 00 00 00 00 00  50 71 04 6d 01 00 00 00  00 00 00 00 00 00 00 00  00 00 00 00
              ^ 
SUMMARY: UndefinedBehaviorSanitizer: undefined-behavior code.c:26:9 in 
code.c:26:9: runtime error: load of misaligned address 0x00016d0471e8 for type 'struct __darwin_mcontext64 *', which requires 16 byte alignment
0x00016d0471e8: note: pointer points here
 00 00 00 00  f0 71 04 6d 01 00 00 00  00 00 ea 02 01 00 00 00  0f 00 00 92 00 00 00 00  41 41 41 41
              ^ 
SUMMARY: UndefinedBehaviorSanitizer: undefined-behavior code.c:26:9 in 
Thread 0 Crashed:: Dispatch queue: com.apple.main-thread
0   dyld                          	0x0000000102ea4000 0x102ea4000 + 0
1   code				                  	0x0000000102dbbcc4 sprr_test + 80 (code.c:92)
2   code        				          	0x0000000102dbb684 main + 172 (code.c:122)
3   libdyld.dylib                 	0x0000000186c89420 start + 4
Thread 0 crashed with ARM Thread State (64-bit):
    x0: 0x0000000041414141   x1: 0x0000000000000000   x2: 0x0000000000000007   x3: 0x0000000000041802
    x4: 0x00000000ffffffff   x5: 0x0000000000000000   x6: 0x0000000000000000   x7: 0x0000000000000000
    x8: 0x0000000102ea0000   x9: 0x0000000041414141  x10: 0x0000000000000000  x11: 0x00000001fe0525cb
   x12: 0x00000001fe0525cb  x13: 0x0000000000000033  x14: 0x0000000000000881  x15: 0x000000008000001f
   x16: 0x00000000000000c5  x17: 0x0000000102ec5f24  x18: 0x0000000000000000  x19: 0x2010000030000000
   x20: 0x0000000102ea0000  x21: 0x0000000000000000  x22: 0x0000000000000000  x23: 0x0000000000000000
   x24: 0x0000000000000000  x25: 0x0000000000000000  x26: 0x0000000000000000  x27: 0x0000000000000000
   x28: 0x000000016d047648   fp: 0x000000016d047590   lr: 0x0000000102dbbd98
    sp: 0x000000016d047590   pc: 0x0000000102ea4000 cpsr: 0x60000000
   far: 0x0000000102ea3ffc  esr: 0x02000000
Binary Images:
       0x102db8000 -        0x102dbbfff +smoke32-user (0) /Users/USER/*/smoke32-user
       0x102ea4000 -        0x102f23fff  dyld (851.27)  /usr/lib/dyld
       0x102fac000 -        0x102fd7fff +libclang_rt.ubsan_osx_dynamic.dylib (1205.0.22.9) ../clang/12.0.5/lib/darwin/libclang_rt.ubsan_osx_dynamic.dylib
```

