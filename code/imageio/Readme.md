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
rm -rf CMakeScripts CMakeFiles Release Debug Build build
```
## Output
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
