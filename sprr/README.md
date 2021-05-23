### M1 SPRR Profiling, Reporting and Build Info

Orignal Blog Post: https://blog.svenpeter.dev/posts/m1_sprr_gxf/
 
 Comments, Build, Profiling Instructions added by dhoyt | @h02332 on May 23, 2021
 UBSAN Report with Xcode Profiling Instructions

BUILD 
---------
 	clang -fprofile-instr-generate -fcoverage-mapping -mllvm -runtime-counter-relocation -g -fsanitize=undefined -O0 -o a.out code.c
 
PROFILE 
--------
 	LLVM_PROFILE_FILE=default.profraw ./a.out
	xcrun llvm-profdata merge -sparse default.profraw -o a.profdata
	xcrun llvm-cov show ./a.out -instr-profile=.profdata

REPORT
--------
 xcrun llvm-cov show ./a.out -instr-profile=a.profdata --show-regions=0 -show-line-counts-or-regions -show-instantiation-summary
 xcrun llvm-cov report ./a.out -instr-profile=.profdata
 sudo gcovr --gcov-executable "xcrun llvm-cov gcov" -r . --html --html-details -o out.html

RUN
	LLVM_PROFILE_FILE=default.profraw ./a.out
