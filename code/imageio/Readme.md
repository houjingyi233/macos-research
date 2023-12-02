# Generic Fuzzer for ImageIO 
The code originated from Google Project Zero
- https://github.com/googleprojectzero/Jackalope/blob/main/examples/ImageIO/imageio.m

### Code Modifications
- Removed are the references for Windows to focus on native X86_64 and arm64e Fuzzing
- The code adds a few supported file types and cleans up the autorelease pool use

### Suggested Build
```
cmake  -G Xcode
cmake --build . --config Debug
```
### Suggested Run
```
cd Debug
stdbuf -oL ./fuzzer -in /fuzz/img/ -out /tmp/out -t 200 -t1 5000 -delivery shmem -instrument_module ImageIO -target_module test_imageio -target_method _fuzz -nargs 1 -iterations 10000 -persist -loop -cmp_coverage -generate_unwind -nthreads 20 -- ../examples/ImageIO/Debug/test_imageio -m @@ | grep -E 'Fuzzer version|input files read|Running input sample|Total execs|Unique samples|Crashes|Hangs|Offsets|Execs/s|WARNING|Width'
```
### For your zsh
```
export CG_PDF_VERBOSE=1
export CG_CONTEXT_SHOW_BACKTRACE=1
export CG_CONTEXT_SHOW_BACKTRACE_ON_ERROR=1
export CG_IMAGE_SHOW_MALLOC=1
export CG_LAYER_SHOW_BACKTRACE=1
export CGBITMAP_CONTEXT_LOG=1
export CGCOLORDATAPROVIDER_VERBOSE=1
export CGPDF_LOG_PAGES=1
```
### For your clean
```
rm -rf CMakeScripts CMakeFiles Release Debug build
```
## Program Output
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
## Bitmap Context Notes

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

#### Cache Reset
```
qlmanage -r
qlmanage -r cache
```
## Tracing Debug Info
```
CG_PDF_VERBOSE=1 CG_CONTEXT_SHOW_BACKTRACE=1 CG_CONTEXT_SHOW_BACKTRACE_ON_ERROR=1 CG_IMAGE_SHOW_MALLOC=1 CG_LAYER_SHOW_BACKTRACE=1 CGBITMAP_CONTEXT_LOG=1 CGCOLORDATAPROVIDER_VERBOSE=1 CGPDF_LOG_PAGES=1 ../TinyInst/Debug/litecov -trace_debug_events -- ../examples/ImageIO/Debug/test_imageio -f ~/Documents/fuzz/img
```
#### Tracing Output
```
Debugger: Mach exception (5) @ address 0x10cae4040
Debugger: Process created or attached
Debugger: Loaded module dyld at 0x10cadf000
Debugger: Loaded module test_imageio at 0x10938b000
Debugger: Loaded module ImageIO at 0x7ff811f15000
Debugger: Loaded module CoreFoundation at 0x7ff80733b000
Debugger: Loaded module Foundation at 0x7ff8082f3000
Debugger: Loaded module CoreGraphics at 0x7ff80cd73000
Debugger: Loaded module IOSurface at 0x7ff81172d000
Debugger: Loaded module Accelerate at 0x7ff81bd75000
Debugger: Loaded module AppleJPEG at 0x7ff81618b000
Debugger: Loaded module Security at 0x7ff809ea7000
Debugger: Loaded module CoreAnalytics at 0x7ff80f095000
Debugger: Loaded module libexpat.1.dylib at 0x7ff815cb5000
Debugger: Loaded module libz.1.dylib at 0x7ff81405d000
Debugger: Loaded module libcompression.dylib at 0x7ff8142e6000
Debugger: Loaded module ColorSync at 0x7ff80d52c000
Debugger: Loaded module libPng.dylib at 0x7ff816872000
Debugger: Loaded module libTIFF.dylib at 0x7ff81689f000
Debugger: Loaded module libGIF.dylib at 0x7ff816994000
Debugger: Loaded module libJP2.dylib at 0x7ff8161d7000
Debugger: Loaded module libate.dylib at 0x7ff81599d000
Debugger: Loaded module libJPEG.dylib at 0x7ff816933000
Debugger: Loaded module libRadiance.dylib at 0x7ff81692a000
Debugger: Loaded module CoreServices at 0x7ff81ba70000
Debugger: Loaded module Metal at 0x7ff81174c000
Debugger: Loaded module libobjc.A.dylib at 0x7ff806f0b000
Debugger: Loaded module libc++.1.dylib at 0x7ff807203000
Debugger: Loaded module libSystem.B.dylib at 0x7ff814148000
Debugger: Loaded module CoreServicesInternal at 0x7ff80a7df000
Debugger: Loaded module liboah.dylib at 0x7ff814114000
Debugger: Loaded module libfakelink.dylib at 0x7ff81414a000
Debugger: Loaded module libicucore.A.dylib at 0x7ff80a244000
Debugger: Loaded module SoftLinking at 0x7ff81414e000
Debugger: Loaded module libc++abi.dylib at 0x7ff807282000
Debugger: Loaded module libcache.dylib at 0x7ff814142000
Debugger: Loaded module libcommonCrypto.dylib at 0x7ff8140fd000
Debugger: Loaded module libcompiler_rt.dylib at 0x7ff814126000
Debugger: Loaded module libcopyfile.dylib at 0x7ff81411c000
Debugger: Loaded module libcorecrypto.dylib at 0x7ff80704c000
Debugger: Loaded module libdispatch.dylib at 0x7ff807131000
Debugger: Loaded module libdyld.dylib at 0x7ff8072e2000
Debugger: Loaded module libkeymgr.dylib at 0x7ff814138000
Debugger: Loaded module libmacho.dylib at 0x7ff8140d9000
Debugger: Loaded module libquarantine.dylib at 0x7ff813571000
Debugger: Loaded module libremovefile.dylib at 0x7ff814136000
Debugger: Loaded module libsystem_asl.dylib at 0x7ff80c8ea000
Debugger: Loaded module libsystem_blocks.dylib at 0x7ff806fea000
Debugger: Loaded module libsystem_c.dylib at 0x7ff80717b000
Debugger: Loaded module libsystem_collections.dylib at 0x7ff81412e000
Debugger: Loaded module libsystem_configuration.dylib at 0x7ff81268f000
Debugger: Loaded module libsystem_containermanager.dylib at 0x7ff811704000
Debugger: Loaded module libsystem_coreservices.dylib at 0x7ff813d36000
Debugger: Loaded module libsystem_darwin.dylib at 0x7ff80a4da000
Debugger: Loaded module libsystem_darwindirectory.dylib at 0x7ffc1be29000
Debugger: Loaded module libsystem_dnssd.dylib at 0x7ff814139000
Debugger: Loaded module libsystem_featureflags.dylib at 0x7ff807178000
Debugger: Loaded module libsystem_info.dylib at 0x7ff807310000
Debugger: Loaded module libsystem_m.dylib at 0x7ff814071000
Debugger: Loaded module libsystem_malloc.dylib at 0x7ff8070f8000
Debugger: Loaded module libsystem_networkextension.dylib at 0x7ff80c860000
Debugger: Loaded module libsystem_notify.dylib at 0x7ff80a923000
Debugger: Loaded module libsystem_sandbox.dylib at 0x7ff812693000
Debugger: Loaded module libsystem_secinit.dylib at 0x7ff814133000
Debugger: Loaded module libsystem_kernel.dylib at 0x7ff80729b000
Debugger: Loaded module libsystem_platform.dylib at 0x7ff807306000
Debugger: Loaded module libsystem_pthread.dylib at 0x7ff8072d6000
Debugger: Loaded module libsystem_symptoms.dylib at 0x7ff80e461000
Debugger: Loaded module libsystem_trace.dylib at 0x7ff807032000
Debugger: Loaded module libunwind.dylib at 0x7ff814109000
Debugger: Loaded module libxpc.dylib at 0x7ff806fee000
Debugger: Loaded module IOKit at 0x7ff80a860000
Debugger: Loaded module libDiagnosticMessagesClient.dylib at 0x7ff80f0c1000
Debugger: Loaded module libenergytrace.dylib at 0x7ff80c878000
Debugger: Loaded module libbsm.0.dylib at 0x7ff813598000
Debugger: Loaded module libkxld.dylib at 0x7ff8140e1000
Debugger: Loaded module CFNetwork at 0x7ff80c4b3000
Debugger: Loaded module FSEvents at 0x7ff80fee8000
Debugger: Loaded module CarbonCore at 0x7ff80a4e5000
Debugger: Loaded module Metadata at 0x7ff80f109000
Debugger: Loaded module OSServices at 0x7ff813d3c000
Debugger: Loaded module SearchKit at 0x7ff814225000
Debugger: Loaded module AE at 0x7ff80e3e7000
Debugger: Loaded module LaunchServices at 0x7ff8077d6000
Debugger: Loaded module DictionaryServices at 0x7ff8156fd000
Debugger: Loaded module SharedFileList at 0x7ff80fef5000
Debugger: Loaded module SystemConfiguration at 0x7ff807fac000
Debugger: Loaded module libapple_nghttp2.dylib at 0x7ff8142af000
Debugger: Loaded module libsqlite3.dylib at 0x7ff80e077000
Debugger: Loaded module Network at 0x7ff80e469000
Debugger: Loaded module libCoreEntitlements.dylib at 0x7ffc1a4ad000
Debugger: Loaded module MessageSecurity at 0x7ffb22e81000
Debugger: Loaded module ProtocolBuffer at 0x7ff80e05e000
Debugger: Loaded module libMobileGestalt.dylib at 0x7ff80c879000
Debugger: Loaded module AppleFSCompression at 0x7ff813c59000
Debugger: Loaded module libcoretls.dylib at 0x7ff813580000
Debugger: Loaded module libcoretls_cfhelpers.dylib at 0x7ff815765000
Debugger: Loaded module libpam.2.dylib at 0x7ff8142e0000
Debugger: Loaded module libxar.1.dylib at 0x7ff8157dd000
Debugger: Loaded module CoreAutoLayout at 0x7ff80ff20000
Debugger: Loaded module DiskArbitration at 0x7ff80f1a1000
Debugger: Loaded module libarchive.2.dylib at 0x7ff81419c000
Debugger: Loaded module libxml2.2.dylib at 0x7ff80ff69000
Debugger: Loaded module liblangid.dylib at 0x7ff81269e000
Debugger: Loaded module Combine at 0x7ff8198d0000
Debugger: Loaded module CollectionsInternal at 0x7ffb120da000
Debugger: Loaded module ReflectionInternal at 0x7ffc0738b000
Debugger: Loaded module RuntimeInternal at 0x7ffc0796c000
Debugger: Loaded module libswiftCore.dylib at 0x7ff817526000
Debugger: Loaded module libswiftCoreFoundation.dylib at 0x7ff90d0f5000
Debugger: Loaded module libswiftDarwin.dylib at 0x7ff90b02c000
Debugger: Loaded module libswiftDispatch.dylib at 0x7ff81d3df000
Debugger: Loaded module libswiftIOKit.dylib at 0x7ff90d133000
Debugger: Loaded module libswiftObjectiveC.dylib at 0x7ff81fb51000
Debugger: Loaded module libswiftXPC.dylib at 0x7ff90d105000
Debugger: Loaded module libswift_Concurrency.dylib at 0x7ffc1bb0d000
Debugger: Loaded module libswift_StringProcessing.dylib at 0x7ffc1bc48000
Debugger: Loaded module libswiftos.dylib at 0x7ff81fb55000
Debugger: Loaded module AppleSystemInfo at 0x7ff81269a000
Debugger: Loaded module libpcap.A.dylib at 0x7ff81414f000
Debugger: Loaded module libdns_services.dylib at 0x7ff80e457000
Debugger: Loaded module libnetwork.dylib at 0x7ff80c4b2000
Debugger: Loaded module IOMobileFramebuffer at 0x7ff813299000
Debugger: Loaded module liblzma.5.dylib at 0x7ff81574c000
Debugger: Loaded module libswift_RegexParser.dylib at 0x7ffc1bb94000
Debugger: Loaded module libbz2.1.0.dylib at 0x7ff813d27000
Debugger: Loaded module libiconv.2.dylib at 0x7ff814184000
Debugger: Loaded module libcharset.1.dylib at 0x7ff8140d5000
Debugger: Loaded module libheimdal-asn1.dylib at 0x7ff815cd0000
Debugger: Loaded module libCheckFix.dylib at 0x7ff813574000
Debugger: Loaded module TCC at 0x7ff80c901000
Debugger: Loaded module CoreNLP at 0x7ff8126a0000
Debugger: Loaded module MetadataUtilities at 0x7ff80f0c3000
Debugger: Loaded module libmecab.dylib at 0x7ff8135a8000
Debugger: Loaded module libCRFSuite.dylib at 0x7ff808033000
Debugger: Loaded module libgermantok.dylib at 0x7ff813601000
Debugger: Loaded module libThaiTokenizer.dylib at 0x7ff81428b000
Debugger: Loaded module vImage at 0x7ff80f1a9000
Debugger: Loaded module vecLib at 0x7ff81ba43000
Debugger: Loaded module libvMisc.dylib at 0x7ff81581f000
Debugger: Loaded module libvDSP.dylib at 0x7ff813089000
Debugger: Loaded module libBLAS.dylib at 0x7ff807bdc000
Debugger: Loaded module libLAPACK.dylib at 0x7ff8143c6000
Debugger: Loaded module libLinearAlgebra.dylib at 0x7ff813604000
Debugger: Loaded module libSparseBLAS.dylib at 0x7ff8142ca000
Debugger: Loaded module libQuadrature.dylib at 0x7ff8143c0000
Debugger: Loaded module libBNNS.dylib at 0x7ff8127af000
Debugger: Loaded module libSparse.dylib at 0x7ff807f34000
Debugger: Loaded module MIL at 0x7ffb217cf000
Debugger: Loaded module CFOpenDirectory at 0x7ff80fecc000
Debugger: Loaded module OpenDirectory at 0x7ff80fec0000
Debugger: Loaded module APFS at 0x7ff815767000
Debugger: Loaded module SecurityFoundation at 0x7ff8134ba000
Debugger: Loaded module libutil.dylib at 0x7ff8157eb000
Debugger: Loaded module InstalledContentLibrary at 0x7ffb1fc9c000
Debugger: Loaded module CoreServicesStore at 0x7ff80a820000
Debugger: Loaded module libapp_launch_measurement.dylib at 0x7ff80ff1d000
Debugger: Loaded module AppleMobileFileIntegrity at 0x7ffb1000d000
Debugger: Loaded module libmis.dylib at 0x7ff90d0d5000
Debugger: Loaded module MobileSystemServices at 0x7ff91d1c5000
Debugger: Loaded module ConfigProfileHelper at 0x7ffa1ab5c000
Debugger: Loaded module AppleSauce at 0x7ff81428d000
Debugger: Loaded module LanguageModeling at 0x7ff808f32000
Debugger: Loaded module libxslt.1.dylib at 0x7ff8157ef000
Debugger: Loaded module libcmph.dylib at 0x7ff81418b000
Debugger: Loaded module CoreEmoji at 0x7ff813268000
Debugger: Loaded module LinguisticData at 0x7ff8127aa000
Debugger: Loaded module Lexicon at 0x7ff807e51000
Debugger: Loaded module BackgroundTaskManagement at 0x7ff813543000
Debugger: Loaded module libTLE.dylib at 0x7ffc1a629000
Debugger: Loaded module SkyLight at 0x7ff80c91f000
Debugger: Loaded module libFontParser.dylib at 0x7ff811ac7000
Debugger: Loaded module RunningBoardServices at 0x7ff80e388000
Debugger: Loaded module IOSurfaceAccelerator at 0x7ff82245b000
Debugger: Loaded module WatchdogClient at 0x7ff8162c5000
Debugger: Loaded module CoreDisplay at 0x7ff8090fb000
Debugger: Loaded module CoreMedia at 0x7ff811999000
Debugger: Loaded module IOAccelerator at 0x7ff811743000
Debugger: Loaded module CoreVideo at 0x7ff810048000
Debugger: Loaded module MetalPerformanceShaders at 0x7ff8142de000
Debugger: Loaded module MultitouchSupport at 0x7ff8162c9000
Debugger: Loaded module QuartzCore at 0x7ff80f858000
Debugger: Loaded module VideoToolbox at 0x7ff816306000
Debugger: Loaded module UserManagement at 0x7ff8100d4000
Debugger: Loaded module BaseBoard at 0x7ff80e2ba000
Debugger: Loaded module MobileKeyBag at 0x7ff813497000
Debugger: Loaded module AggregateDictionary at 0x7ff812699000
Debugger: Loaded module AppleKeyStore at 0x7ffb0ff91000
Debugger: Loaded module GPUWrangler at 0x7ff816923000
Debugger: Loaded module IOPresentment at 0x7ff816907000
Debugger: Loaded module DSExternalDisplay at 0x7ff81692d000
Debugger: Loaded module libllvm-flatbuffers.dylib at 0x7ffb1bd2e000
Debugger: Loaded module libCoreFSCache.dylib at 0x7ffa228a1000
Debugger: Loaded module libGPUCompilerUtils.dylib at 0x7ffb188ae000
Debugger: Loaded module CMCaptureCore at 0x7ff81699a000
Debugger: Loaded module libspindump.dylib at 0x7ff815e93000
Debugger: Loaded module CoreAudio at 0x7ff809799000
Debugger: Loaded module ExtensionFoundation at 0x7ffb08be1000
Debugger: Loaded module CoreTime at 0x7ff81dc06000
Debugger: Loaded module AppServerSupport at 0x7ff815e7d000
Debugger: Loaded module perfdata at 0x7ff8183fe000
Debugger: Loaded module AudioToolboxCore at 0x7ff809227000
Debugger: Loaded module caulk at 0x7ff811973000
Debugger: Loaded module libAudioStatistics.dylib at 0x7ff817c9c000
Debugger: Loaded module SystemPolicy at 0x7ff90c4ce000
Debugger: Loaded module libSMC.dylib at 0x7ff817f68000
Debugger: Loaded module CoreMIDI at 0x7ff821b4b000
Debugger: Loaded module libAudioToolboxUtility.dylib at 0x7ff816839000
Debugger: Loaded module OSAServicesClient at 0x7ff907f35000
Debugger: Loaded module libperfcheck.dylib at 0x7ff81840b000
Debugger: Loaded module PlugInKit at 0x7ff815b96000
Debugger: Loaded module AssertionServices at 0x7ff8134ad000
Debugger: Loaded module libswiftMetal.dylib at 0x7ff9190f3000
Debugger: Loaded module libswiftQuartzCore.dylib at 0x7ff91ccf8000
Debugger: Loaded module libswiftsimd.dylib at 0x7ff91038e000
Debugger: Loaded module CoreImage at 0x7ff812244000
Debugger: Loaded module Symbolication at 0x7ffa09c8a000
Debugger: Loaded module CoreText at 0x7ff809594000
Debugger: Loaded module PhotosensitivityProcessing at 0x7ffb26452000
Debugger: Loaded module OpenGL at 0x7ffa228ad000
Debugger: Loaded module OpenCL at 0x7ffa23ead000
Debugger: Loaded module GraphVisualizer at 0x7ff815e28000
Debugger: Loaded module libGLU.dylib at 0x7ffa228fe000
Debugger: Loaded module libGFXShared.dylib at 0x7ffa228c0000
Debugger: Loaded module libGL.dylib at 0x7ffa22abd000
Debugger: Loaded module libGLImage.dylib at 0x7ffa228c8000
Debugger: Loaded module libCVMSPluginSupport.dylib at 0x7ffa228bd000
Debugger: Loaded module libRosetta.dylib at 0x7ffc1a5e3000
Debugger: Loaded module libCoreVMClient.dylib at 0x7ffa228a8000
Debugger: Loaded module FontServices at 0x7ffb169ec000
Debugger: Loaded module UniformTypeIdentifiers at 0x7ff80bf69000
Debugger: Loaded module OTSVG at 0x7ff815e37000
Debugger: Loaded module libFontRegistry.dylib at 0x7ff80fc00000
Debugger: Loaded module libhvf.dylib at 0x7ff815e87000
Debugger: Loaded module libXTFontStaticRegistryData.dylib at 0x7ffb169ed000
Debugger: Loaded module MPSCore at 0x7ff81260e000
Debugger: Loaded module MPSImage at 0x7ff813bbf000
Debugger: Loaded module MPSNeuralNetwork at 0x7ff81361a000
Debugger: Loaded module MPSMatrix at 0x7ff813a93000
Debugger: Loaded module MPSRayIntersector at 0x7ff813846000
Debugger: Loaded module MPSNDArray at 0x7ff813ace000
Debugger: Loaded module MPSFunctions at 0x7ffb0a8a5000
Debugger: Loaded module MPSBenchmarkLoop at 0x7ffb0a887000
Debugger: Loaded module MetalTools at 0x7ff807a8c000
Debugger: Loaded module IOAccelMemoryInfo at 0x7ff9116c8000
Debugger: Loaded module kperf at 0x7ff91d0d7000
Debugger: Loaded module GPURawCounter at 0x7ff90d0e8000
Debugger: Loaded module CoreSymbolication at 0x7ff81dafa000
Debugger: Loaded module MallocStackLogging at 0x7ff90d0a6000
Debugger: Loaded module CrashReporterSupport at 0x7ff815a3d000
Debugger: Loaded module DebugSymbols at 0x7ff81dabb000
Debugger: Loaded module OSAnalytics at 0x7ff91c40a000
Debugger: Loaded module VideoToolboxParavirtualizationSupport at 0x7ffc11b55000
Debugger: Loaded module AppleVA at 0x7ff815c65000
Debugger: Loaded module AppKit at 0x7ff80a987000
Debugger: Loaded module UIFoundation at 0x7ff80bd8d000
Debugger: Loaded module CollectionViewCore at 0x7ffb120c5000
Debugger: Loaded module RemoteViewServices at 0x7ff81b620000
Debugger: Loaded module XCTTargetBootstrap at 0x7ff811ed7000
Debugger: Loaded module InternationalSupport at 0x7ff816adc000
Debugger: Loaded module UserActivity at 0x7ff816b65000
Debugger: Loaded module WindowManagement at 0x7ffc13401000
Debugger: Loaded module CoreData at 0x7ff80dbe4000
Debugger: Loaded module CoreSVG at 0x7ff811edc000
Debugger: Loaded module IconServices at 0x7ff815cf7000
Debugger: Loaded module ApplicationServices at 0x7ff81f6ef000
Debugger: Loaded module DFRFoundation at 0x7ff811ec3000
Debugger: Loaded module AudioToolbox at 0x7ff817aae000
Debugger: Loaded module DataDetectorsCore at 0x7ff816ae8000
Debugger: Loaded module TextInput at 0x7ff91042c000
Debugger: Loaded module HIToolbox at 0x7ff811c27000
Debugger: Loaded module SpeechRecognition at 0x7ff81b658000
Debugger: Loaded module CoreUI at 0x7ff80fc4c000
Debugger: Loaded module RenderBox at 0x7ff82606f000
Debugger: Loaded module PerformanceAnalysis at 0x7ff80feb4000
Debugger: Loaded module Accessibility at 0x7ff81b9e7000
Debugger: Loaded module CoreTransferable at 0x7ffb086b6000
Debugger: Loaded module DeveloperToolsSupport at 0x7ffb08aff000
Debugger: Loaded module Symbols at 0x7ffb0d0b7000
Debugger: Loaded module libswiftCoreGraphics.dylib at 0x7ff90b025000
Debugger: Loaded module libswiftCoreImage.dylib at 0x7ff90d132000
Debugger: Loaded module libswiftOSLog.dylib at 0x7ff925b50000
Debugger: Loaded module libswiftUniformTypeIdentifiers.dylib at 0x7ff920d6b000
Debugger: Loaded module TextureIO at 0x7ff816a1c000
Debugger: Loaded module ATS at 0x7ff817ce0000
Debugger: Loaded module HIServices at 0x7ff80d6d9000
Debugger: Loaded module PrintCore at 0x7ff8169a8000
Debugger: Loaded module QD at 0x7ff8180be000
Debugger: Loaded module ColorSyncLegacy at 0x7ff8180b6000
Debugger: Loaded module SpeechSynthesis at 0x7ff817cb4000
Debugger: Loaded module ATSUI at 0x7ff816964000
Debugger: Loaded module libcups.2.dylib at 0x7ff818048000
Debugger: Loaded module Kerberos at 0x7ff81841a000
Debugger: Loaded module GSS at 0x7ff818429000
Debugger: Loaded module libresolv.9.dylib at 0x7ff817d59000
Debugger: Loaded module Heimdal at 0x7ff815e99000
Debugger: Loaded module libHeimdalProxy.dylib at 0x7ff81fabe000
Debugger: Loaded module CommonAuth at 0x7ff818476000
Debugger: Loaded module AVFAudio at 0x7ffb07ad7000
Debugger: Loaded module AXCoreUtilities at 0x7ff907f7e000
Debugger: Loaded module AudioSession at 0x7ff817c24000
Debugger: Loaded module IOBluetooth at 0x7ff819698000
Debugger: Loaded module MediaExperience at 0x7ff815d74000
Debugger: Loaded module libSessionUtility.dylib at 0x7ff817a79000
Debugger: Loaded module AudioResourceArbitration at 0x7ff8180ca000
Debugger: Loaded module PowerLog at 0x7ff81c77c000
Debugger: Loaded module CoreBluetooth at 0x7ff81c69d000
Debugger: Loaded module AudioUnit at 0x7ff81fabf000
Debugger: Loaded module CoreUtils at 0x7ff813321000
Debugger: Loaded module CoreUtilsExtras at 0x7ffb151c1000
Debugger: Loaded module IO80211 at 0x7ffb1fb29000
Debugger: Loaded module libAccessibility.dylib at 0x7ff907f95000
Debugger: Loaded module MediaAccessibility at 0x7ff81bdbd000
Debugger: Loaded module FrontBoardServices at 0x7ff81d61a000
Debugger: Loaded module BackBoardServices at 0x7ff81f0b7000
Debugger: Loaded module BoardServices at 0x7ff81d6d6000
Debugger: Loaded module IconFoundation at 0x7ff815cd9000
Debugger: Loaded module SpeechRecognitionCore at 0x7ff81b648000
Debugger: Loaded module OSLog at 0x7ffa0d3ff000
Debugger: Loaded module LoggingSupport at 0x7ff90d033000
Debugger: Process entrypoint reached
Debugger: Loaded module RawCamera at 0x7ff915cc2000
Debugger: Loaded module MobileAsset at 0x7ff818486000
Debugger: Loaded module AppleJPEGXL at 0x7ffb0fd05000
Debugger: Loaded module SoftwareUpdateCoreSupport at 0x7ff912d8b000
Debugger: Loaded module SoftwareUpdateCoreConnect at 0x7ff91a4e7000
Debugger: Loaded module StreamingZip at 0x7ff81fae3000
Debugger: Loaded module RemoteServiceDiscovery at 0x7ff81f336000
Debugger: Loaded module MSUDataAccessor at 0x7ff912a21000
Debugger: Loaded module libbootpolicy.dylib at 0x7ff90ebd4000
Debugger: Loaded module libpartition2_dynamic.dylib at 0x7ff920f4d000
Debugger: Loaded module CMPhoto at 0x7ffb1126b000
Debugger: Loaded module AppleVPA at 0x7ff81d98d000
Debugger: Loaded module MediaToolbox at 0x7ff816bd1000
Debugger: Loaded module CoreAVCHD at 0x7ff81cd33000
Debugger: Loaded module Mangrove at 0x7ff81cd2f000
Debugger: Loaded module CoreWiFi at 0x7ff81eefd000
Debugger: Loaded module CoreTelephony at 0x7ff81d2c2000
Debugger: Loaded module CoreAUC at 0x7ff81c974000
Debugger: Loaded module WiFiPeerToPeer at 0x7ffa13fd1000
Debugger: Loaded module UserNotifications at 0x7ff813f0c000
Debugger: Loaded module libTelephonyUtilDynamic.dylib at 0x7ff8185af000
Debugger: Process exit
Process finished normally
```

### TinyInst Crash File Reproduction 
```
../TinyInst/Debug/litecov -trace_debug_events -- ../examples/ImageIO/Debug/test_imageio -f /tmp/out/crashes/other_0xxxxxxxxxx7ce_0x0_1
```

#### TinyInst Reproduction Output
```
...
Debugger: Process entrypoint reached
Debugger: Loaded module RawCamera at 0x7ff915cc2000
Debugger: Loaded module MobileAsset at 0x7ff818486000
Debugger: Loaded module AppleJPEGXL at 0x7ffb0fd05000
Debugger: Loaded module SoftwareUpdateCoreSupport at 0x7ff912d8b000
Debugger: Loaded module SoftwareUpdateCoreConnect at 0x7ff91a4e7000
Debugger: Loaded module StreamingZip at 0x7ff81fae3000
Debugger: Loaded module RemoteServiceDiscovery at 0x7ff81f336000
Debugger: Loaded module MSUDataAccessor at 0x7ff912a21000
Debugger: Loaded module libbootpolicy.dylib at 0x7ff90ebd4000
Debugger: Loaded module libpartition2_dynamic.dylib at 0x7ff920f4d000
Debugger: Loaded module CMPhoto at 0x7ffb1126b000
Debugger: Loaded module AppleVPA at 0x7ff81d98d000
Debugger: Loaded module MediaToolbox at 0x7ff816bd1000
Debugger: Loaded module CoreAVCHD at 0x7ff81cd33000
Debugger: Loaded module Mangrove at 0x7ff81cd2f000
Debugger: Loaded module CoreWiFi at 0x7ff81eefd000
Debugger: Loaded module CoreTelephony at 0x7ff81d2c2000
Debugger: Loaded module CoreAUC at 0x7ff81c974000
Debugger: Loaded module WiFiPeerToPeer at 0x7ffa13fd1000
Debugger: Loaded module UserNotifications at 0x7ff813f0c000
Debugger: Loaded module libTelephonyUtilDynamic.dylib at 0x7ff8185af000
Debugger: Loaded module libAppleEXR.dylib at 0x7ffa0d712000
Debugger: Loaded module libCGInterfaces.dylib at 0x7ff9123e6000
libc++abi: terminating due to uncaught exception of type int
Debugger: Mach exception (5) @ address 0x7ff8072a37ce
Exception at address 0x7ff8072a37ce
Process crashed
Debugger: Process exit
```
