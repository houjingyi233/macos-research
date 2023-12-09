# Jackalope Fuzzer for ImageIO + Other Dylibs
The code originated from Google Project Zero
- https://github.com/googleprojectzero/Jackalope/blob/main/examples/ImageIO/imageio.m
- I modified the code and wrote some examples to cross-check some Bug I sent to Apple Product Security 
## My Code Modifications
- Removed are the references for Windows to focus on native X86_64 and arm64e Fuzzing
- The code adds a few supported file types and cleans up the autorelease pool use
- The Script and Examples show how to Target other Dylibs depending on the Image Type, or Fuzz them all with the sample Script [https://raw.githubusercontent.com/xsscx/macos-research/main/code/imageio/imageio-fuzzer.zsh]
## Suggested Build
```
cmake  -G Xcode
cmake --build . --config Debug
```
## Suggested clean
```
rm -rf CMakeScripts CMakeFiles Release Debug build
cmake --build . --target clean
```
## Jackalope Example Command Lines
#### Run Fuzzer with ASAN against CoreSVG with SVG UTT File Types
```
ASAN_OPTIONS=strict_string_checks=0:detect_stack_use_after_return=1:check_initialization_order=1:strict_init_order=1:print_stats=1:print_legend=1:dump_instruction_bytes=1:fast_unwind_on_fatal=1:debug=true:abort_on_error=1:symbolize=1:verbosity=3 stdbuf -oL ./fuzzer  -target_env DYLD_INSERT_LIBRARIES=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/15.0.0/lib/darwin/libclang_rt.tsan_osx_dynamic.dylib  -dump_coverage    -in /mnt/fuzz/svg -out /tmp/svg -t 200 -t1 500 -delivery shmem -instrument_module CoreSVG -target_module test_imageio -target_method _fuzz -nargs 1 -iterations 100 -persist -loop -cmp_coverage -generate_unwind -nthreads 20 -- ../examples/ImageIO/Debug/test_imageio -m @@ | grep -E 'Fuzzer version|input files read|Running input sample|Total execs|Unique samples|Crashes|Hangs|Offsets|Execs/s|WARNING|Width|Sanitizer|Hint|DEADLY'
```
#### Run Fuzzer with TSAN against LibPng with PNG UTT File Types
```
ASAN_OPTIONS=strict_string_checks=0:detect_stack_use_after_return=1:check_initialization_order=1:strict_init_order=1:print_stats=1:print_legend=1:dump_instruction_bytes=1:fast_unwind_on_fatal=1:debug=true:abort_on_error=1:symbolize=1:verbosity=3 stdbuf -oL ./fuzzer  -target_env DYLD_INSERT_LIBRARIES=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/15.0.0/lib/darwin/libclang_rt.tsan_osx_dynamic.dylib  -dump_coverage    -in /mnt/fuzz/png -out /tmp/svg -t 200 -t1 500 -delivery shmem -instrument_module LibPng -target_module test_imageio -target_method _fuzz -nargs 1 -iterations 100 -persist -loop -cmp_coverage -generate_unwind -nthreads 20 -- ../examples/ImageIO/Debug/test_imageio -m @@ | grep -E 'Fuzzer version|input files read|Running input sample|Total execs|Unique samples|Crashes|Hangs|Offsets|Execs/s|WARNING|Width|Sanitizer|Hint|DEADLY'
```
#### Run Fuzzer with libgmalloc.dylib against libJPEG.dylib with JPEG UTT File Types
```
stdbuf -oL ./fuzzer  -target_env MallocStackLogging=1 MallocScribble=1 DYLD_INSERT_LIBRARIES=/usr/lib/libgmalloc.dylib  -in /mnt/fuzz/png -out /mnt/jpg/out -t 200 -t1 500 -delivery shmem -instrument_module libJPEG.dylib -target_module test_imageio -target_method _fuzz -nargs 1 -iterations 1000 -persist -loop -cmp_coverage -generate_unwind -nthreads 20 -- ../examples/ImageIO/Debug/test_imageio -m @@ | grep -E 'Fuzzer version|input files read|Running input sample|Total execs|Fuzzing|Unique samples|Crashes|Hangs|Offsets|Execs/s|WARNING|Width|Sanitizer|Hint|DEADLY'
```
### Fuzzer Output
### Sample for Instrumented module AppleJPEG
```
Total execs: 153265
Unique samples: 107 (100 discarded)
Crashes: 0 (0 unique)
Hangs: 1547
Offsets: 4775
Execs/s: 1093
Fuzzing sample 00101
Instrumented module AppleJPEG, code size: 311288
...
```
#### Sample for Instrumented module libGIF.dylib
````
Total execs: 20504264
Unique samples: 34 (28 discarded)
Crashes: 0 (0 unique)
Hangs: 31486
Offsets: 1066
Execs/s: 2538
Instrumented module libGIF.dylib, code size: 24576
Instrumented module libGIF.dylib, code size: 24576
Fuzzing sample 00027
Fuzzing sample 00002
Fuzzing sample 00001
Instrumented module libGIF.dylib, code size: 24576
Instrumented module libGIF.dylib, code size: 24576
Fuzzing sample 00000
Instrumented module libGIF.dylib, code size: 24576
Instrumented module libGIF.dylib, code size: 24576
````

### Sample for Crash in libAppleEXR.dylib and abort() due to Error in Sub-sampling
```
libAppleEXR.dylib             	       0x1ca82f6e8 axr_error_t LaunchBlocks<ReadPixelsArgs>(void (*)(void*, unsigned long), ReadPixelsArgs const*, unsigned long, axr_flags_t) + 480
libAppleEXR.dylib             	       0x1ca83245c TileDecoder::ReadYccRGBAPixels(double, YccMatrix const&, void*, unsigned long) const + 2384
libAppleEXR.dylib             	       0x1ca825be8 Part::ReadRGBAPixels(axr_decoder*, void*, unsigned long, double, axr_flags_t) const + 2540
ImageIO                       	       0x1919384f4 EXRReadPlugin::decodeBlockAppleEXR(void*, unsigned long) + 364 
```

### Sample Bug Output | Null Pointer DeRef at CoreSVG:x86_64+0x52be
Source URL https://github.com/xsscx/Commodity-Injection-Signatures/tree/master/svg
```
Jackalope Fuzzer version 1.11 with @h02332 SVG Reproduction of a Null Pointer DeRef at CoreSVG:x86_64+0x52be
4 input files read

Running input sample /mnt/fuzz/svg/xss-xml-svg-font-example-poc-1.svg
Running input sample /mnt/fuzz/svg/xss-xml-svg-font-example-poc-2.svg
Running input sample /mnt/fuzz/svg/xss-xml-svg-font-example-poc-3.svg

Total execs: 9
Unique samples: 0 (0 discarded)
Crashes: 0 (0 unique)
Hangs: 0
Offsets: 0
Execs/s: 9
Total execs: 9
Unique samples: 0 (0 discarded)
Crashes: 0 (0 unique)
Hangs: 0
Offsets: 0
Execs/s: 0
[!] WARNING: Target function not reached, retrying with a clean process
[!] WARNING: Target function not reached, retrying with a clean process
[!] WARNING: Target function not reached, retrying with a clean process
[!] WARNING: Target function not reached, retrying with a clean process
[!] WARNING: Target function not reached, retrying with a clean process
[!] WARNING: Target function not reached, retrying with a clean process
[!] WARNING: Input sample has no new stable coverage
[!] WARNING: Input sample resulted in a hang
Total execs: 10
Unique samples: 0 (0 discarded)
Crashes: 0 (0 unique)
Hangs: 1
Offsets: 0
Execs/s: 1
...
ThreadSanitizer:DEADLYSIGNAL
==46560==ERROR: ThreadSanitizer: SEGV on unknown address 0x000000000f22 (pc 0x000000000f22 bp 0x7ff7b8283fe0 sp 0x7ff7b8283b90 T405770)
==46560==Hint: pc points to the zero page.
==46560==The signal is caused by a READ memory access.
==46560==Hint: address points to the zero page.
ThreadSanitizer:DEADLYSIGNAL
==46572==ERROR: ThreadSanitizer: SEGV on unknown address 0x000000000f22 (pc 0x000000000f22 bp 0x7ff7b72e9fe0 sp 0x7ff7b72e9b90 T405825)
==46572==Hint: pc points to the zero page.
==46572==The signal is caused by a READ memory access.
==46572==Hint: address points to the zero page.
```
### More Bugs
```
Running input sample /mnt/fuzz/asan_heap-oob_xxxxxx.exr
Total execs: 27
Unique samples: 0 (0 discarded)
Crashes: 0 (0 unique)
Hangs: 6
Offsets: 0
Execs/s: 1

Running input sample /mnt/fuzz/asan_heap-oob_xxxxxx.exr
AddressSanitizer:DEADLYSIGNAL
=================================================================
==22220==ERROR: AddressSanitizer: BUS on unknown address (pc 0x7ff92818129c bp 0x7ff7bf7b6d00 sp 0x7ff7bf7b6c98 T0)
==22220==The signal is caused by a READ memory access.
==22220==Hint: this fault was caused by a dereference of a high value address (see register values below).  Disassemble the provided pc to learn which register was used.
```
### Tip
```
-target_env DYLD_INSERT_LIBRARIES={path}libclang_rt.asan_osx_dynamic.dylib
-target_env DYLD_INSERT_LIBRARIES={path}libclang_rt.ubsan_osx_dynamic.dylib
-target_env DYLD_INSERT_LIBRARIES={path}libclang_rt.tsan_osx_dynamic.dylib
-target_env DYLD_INSERT_LIBRARIES=/usr/lib/libgmalloc.dylib
```
## Build Other Runners via examples/Imageio/CMakeLists.txt - Add other Code to Run and Target Dylibs for more coverage
```
  add_executable(imageio-test-002_imageio
    imageio-test-003.m
  )

  target_link_libraries(imageio-test-002_imageio
    "-framework ImageIO"
    "-framework AppKit"
    "-framework CoreGraphics"
  )

  add_executable(imageio-test-003_imageio
    imageio-test-003.m
  )

  target_link_libraries(imageio-test-003_imageio
    "-framework ImageIO"
    "-framework AppKit"
    "-framework CoreGraphics"
  )
```
### Example Implementation for 10+ Functions
See URL https://raw.githubusercontent.com/xsscx/macos-research/main/code/iOSOnMac/ios-image-fuzzer-example.m so you can understand the Code shown below and have it running locally.

### Bitmap Context Notes

Creating a bitmap context with CGBitmapContextCreate involves several parameters that define the characteristics of the context, such as the width, height, bit depth, bytes per row, color space, and alpha info. Varying these parameters can significantly alter the behavior and output of the context. Below are 10 permutations of the CGBitmapContextCreate function call, each demonstrating a different configuration:
```
Standard RGB with No Alpha:
CGContextRef ctx = CGBitmapContextCreate(NULL, width, height, 8, 0, colorspace, kCGImageAlphaNone);

Premultiplied First Alpha:
CGContextRef ctx = CGBitmapContextCreate(NULL, width, height, 8, 4 * width, colorspace, kCGImageAlphaPremultipliedFirst);

Non-Premultiplied Alpha:
CGContextRef ctx = CGBitmapContextCreate(NULL, width, height, 8, 4 * width, colorspace, kCGImageAlphaLast);

16-bit Depth Per Component:
CGContextRef ctx = CGBitmapContextCreate(NULL, width, height, 16, 8 * width, colorspace, kCGImageAlphaPremultipliedLast);

Grayscale Without Alpha:
CGColorSpaceRef graySpace = CGColorSpaceCreateDeviceGray();
CGContextRef ctx = CGBitmapContextCreate(NULL, width, height, 8, width, graySpace, kCGImageAlphaNone);
CGColorSpaceRelease(graySpace);

High Dynamic Range (HDR) with Float Components:
CGContextRef ctx = CGBitmapContextCreate(NULL, width, height, 32, 16 * width, colorspace, kCGImageAlphaPremultipliedLast | kCGBitmapFloatComponents);

Bitmap Context with Alpha Only:
CGContextRef ctx = CGBitmapContextCreate(NULL, width, height, 8, width, NULL, kCGImageAlphaOnly);

1-Bit Monochrome:
CGContextRef ctx = CGBitmapContextCreate(NULL, width, height, 1, width / 8, NULL, kCGImageAlphaNone);

Big Endian Pixel Format:
CGContextRef ctx = CGBitmapContextCreate(NULL, width, height, 8, 4 * width, colorspace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);

Little Endian Pixel Format:
CGContextRef ctx = CGBitmapContextCreate(NULL, width, height, 8, 4 * width, colorspace, kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little);
```
Each permutation represents a different way of handling pixel formats, alpha channels, color spaces, and bit depths. The choice of parameters depends on the specific requirements of the image processing task at hand. For example, a grayscale context might be suitable for processing black-and-white images, while a context with HDR and float components would be more appropriate for high-quality image rendering.

### Example Implementation for createBitmapContext8BitInvertedColors(size_t width, size_t height)
```
+CGContextRef createBitmapContext8BitInvertedColors(size_t width, size_t height) {
+    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
+    size_t bytesPerRow = 4 * width;
+    CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Big | kCGImageAlphaNoneSkipLast;
+
+    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, bytesPerRow, colorSpace, bitmapInfo);
+    CGColorSpaceRelease(colorSpace);
+
+    if (context) {
+        unsigned char *data = CGBitmapContextGetData(context);
+        if (data) {
+            size_t bufferLength = width * height * 4;
+            for (size_t i = 0; i < bufferLength; i += 4) {
+                data[i] = 255 - data[i];
+                data[i + 1] = 255 - data[i + 1];
+                data[i + 2] = 255 - data[i + 2];
+            }
+        }
+    }
+    return context;
+}
+
```
### Tinyinst Example to find Graphics Dylibs for File Extensions for target_link_libraries and -instrument_module
```
Debugger: Mach exception (5) @ address 0x113a4e070
Debugger: Process created or attached
Debugger: Loaded module dyld at 0x113a49000
Debugger: Loaded module test_imageio at 0x10e5d0000
Debugger: Loaded module ImageIO at 0x7ff8227fb000
Debugger: Loaded module CoreFoundation at 0x7ff8189e6000
Debugger: Loaded module Foundation at 0x7ff81988e000
Debugger: Loaded module CoreGraphics at 0x7ff81d9ef000
Debugger: Loaded module IOSurface at 0x7ff82200d000
...
Debugger: Loaded module CoreBluetooth at 0x7ff82cae0000
Width: 32, height: 32
Failed to load image.
Failed to load image.
Width: 32, height: 32
Width: 32, height: 32
Width: 400, height: 300
Width: 1280, height: 960
Debugger: Process exit
Process finished normally
```
### Find the dylibs your Image(s) load
Tip - you'll need to know what dylibs and frameworks to target, use tinyinst to show you what gets loaded for a given file type. Use multiple file types, target multiple frameworks and dylibs for Linking. 
I Posted a shell script as example. You're going to see that the script iterates the dylibs and frameworks with the option -instrument_module {} as shown below:
```
-instrument_module ImageIO
-instrument_module CoreSVG
-instrument_module AppleJPEG
....
-instrument_module [Framework | dylib]
```
See the Script for an Example https://raw.githubusercontent.com/xsscx/macos-research/main/code/imageio/imageio-fuzzer.zsh
### Script Targets for -instrument_module
```
libraries=(
    "Accelerate"
    "AppleJPEG"
    "ColorSync"
    "ColorSyncLegacy"
    "CoreAVCHD"
    "CoreGraphics"
    "CoreImage"
    "CoreSVG"
    "CoreText"
    "CoreVideo"
    "IOAccelerator"
    "IOSurface"
    "ImageIO"
    "MIL"
    "MPSBenchmarkLoop"
    "MPSCore"
    "MPSFunctions"
    "MPSImage"
    "MPSMatrix"
    "MPSNDArray"
    "MPSNeuralNetwork"
    "MPSRayIntersector"
    "Mangrove"
    "Metal"
    "MetalPerformanceShaders"
    "MetalTools"
    "OpenCL"
    "OpenGL"
    "OpenGL"
    "PhotosensitivityProcessing"
    "QuartzCore"
    "UniformTypeIdentifiers"
    "libBLAS.dylib"
    "libBNNS.dylib"
    "libCGInterfaces.dylib"
    "libCVMSPluginSupport.dylib"
    "libCoreVMClient.dylib"
    "libGFXShared.dylib"
    "libGIF.dylib"
    "libGL.dylib"
    "libGLImage.dylib"
    "libGLU.dylib"
    "libJP2.dylib"
    "libJPEG.dylib"
    "libLAPACK.dylib"
    "libLinearAlgebra.dylib"
    "libPng.dylib"
    "libRadiance.dylib"
    "libSparse.dylib"
    "libSparseBLAS.dylib"
    "libTIFF.dylib"
    "libvDSP.dylib"
    "libvMisc.dylib"
    "vImage"
    "vecLib" 
)
```
### Coverage Samples
- Sample for libPng
- Sample for CoreSVG
- Sample for libAppleEXr
- Other Sample Coverage

#### qlmanage Cache Reset
```
qlmanage -r
qlmanage -r cache
```
### env vars
```
export CG_PDF_VERBOSE=1
export CG_CONTEXT_SHOW_BACKTRACE=1
export CG_CONTEXT_SHOW_BACKTRACE_ON_ERROR=1
export CG_IMAGE_SHOW_MALLOC=1
export CG_LAYER_SHOW_BACKTRACE=1
export CGBITMAP_CONTEXT_LOG=1
export CGCOLORDATAPROVIDER_VERBOSE=1
export CGPDF_LOG_PAGES=1
export CGBITMAP_CONTEXT_LOG_ERRORS=1
export CG_RASTERIZER_VERBOSE=1
export CG_VERBOSE_COPY_IMAGE_BLOCK_DATA=1
export CG_VERBOSE=1
export CGPDF_VERBOSE=1
export CG_FONT_RENDERER_VERBOSE=1
export CGPDF_DRAW_VERBOSE=1
export CG_POSTSCRIPT_VERBOSE=1
export CG_COLOR_CONVERSION_VERBOSE=1
export CG_IMAGE_LOG_FORCE=1
export CG_INFO=1
export CGPDFCONTEXT_VERBOSE=1
export QuartzCoreDebugEnabled=1
export CI_PRINT_TREE=1
export CORESVG_VERBOSE=1
```
