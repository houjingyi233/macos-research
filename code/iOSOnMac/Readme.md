Updated: Sunday, 26 NOV 2023
# iOSOnMac 
- Original Source URL https://github.com/googleprojectzero/p0tools/tree/master/iOSOnMac
- Updated the Makefile to Build on macOS 14
- The Google CLA gets borked when a Commit comes thru a Github Desktop Client that was configured user@mbp
  - Too Much Pull Request Friction
## Replay
```
sw_vers
ProductName:		macOS
ProductVersion:		14.1.1
BuildVersion:		23B81
```
## Updates
This Pull Request does the following:
- Updates the Makefile to Build the Example Project on macOS 14.1.1 | 23B81
- Adds some print statements to runner
- Removes legacy compile comments at top of interpose.c
- Added arm64e compile and run instructions & examples
- Added Image App Sample for command line - fuzzing is possible too...

### Required
```
sudo nvram boot-args="amfi_get_out_of_my_way=1"
sudo reboot
```
## Build Instruction
- download source
- open terminal
- make
- ./runner main.app/main

### Reproduction
```
% make clean
 [Clean] [iOSOnMac] Starting clean up
rm -rf runner runner_dist interpose.dylib interpose_dist.dylib main.app
 [Info] [iOSOnMac] Clean up completed
% make
 [Build] [iOSOnMac] Starting build for runner
clang -arch arm64   -g -o runner runner.c
codesign -s "79744B7FFC78720777469A82065993CA962BC8E8" --entitlements entitlements.xml --force runner
runner: replacing existing signature
 [Info] [iOSOnMac] Runner build completed
 [Build] [iOSOnMac] Starting build for runner_dist
clang -arch arm64   -g -o runner_dist runner_dist.c
codesign -s "79744B7FFC78720777469A82065993CA962BC8E8" --entitlements entitlements.xml --force runner_dist
runner_dist: replacing existing signature
 [Info] [iOSOnMac] Runner_dist build completed
 [Build] [iOSOnMac] Starting build for interpose.dylib
xcrun -sdk iphoneos clang -arch arm64   -g -shared -o interpose.dylib interpose.c
 [Info] [iOSOnMac] Interpose.dylib build completed
 [Build] [iOSOnMac] Starting build for main.app
xcrun -sdk iphoneos clang -arch arm64   -g -o main main.c interpose.dylib
[2023-11-27 08:18:35] [iOSOnMac] -  Creating main.app...
mkdir -p main.app
cp Info.plist main.app/
mv main main.app/
[2023-11-27 08:18:35] [iOSOnMac] -  Created main.app... Codesigning....
codesign -s "79744B7FFC78720777469A82065993CA962BC8E8" --entitlements entitlements.xml --force main.app
 [Info] [iOSOnMac] Main.app build and packaging completed
 [Build] [iOSOnMac] Starting build for interpose_dist.dylib
xcrun -sdk iphoneos clang -arch arm64   -g -shared -o interpose_dist.dylib interpose_dist.c
 [Info] [iOSOnMac] Interpose_dist.dylib build completed
 [Info] [iOSOnMac] Testing runner...
./runner main.app/main
[+] Child process created with pid: 99976
[*] Instrumenting process with PID 99976...
[*] Attempting to attach to task with PID 99976...
[+] Successfully attached to task with PID 99976
[*] Finding patch point...
[*] _amfi_check_dyld_policy_self at offset 0x6e728 in /usr/lib/dyld
[*] Attaching to target process...
[*] Scanning for /usr/lib/dyld in target's memory...
[*] /usr/lib/dyld mapped at 0x100f04000
[*] Patching _amfi_check_dyld_policy_self...
[+] Sucessfully patched _amfi_check_dyld_policy_self
[*] Sending SIGCONT to continue child
Hello World from iOS!
[*] Child exited with status 0
 [Info] [iOSOnMac] Runner test completed
 [Info] [iOSOnMac] Testing runner_dist...
./runner_dist main.app/main
[*] Preparing to execute iOS binary main.app/main
[+] Child process created with pid: 99987
[*] Patching child process to allow dyld interposing...
[*] _amfi_check_dyld_policy_self at offset 0x6e728 in /usr/lib/dyld
[*] /usr/lib/dyld mapped at 0x1028b0000
[+] Sucessfully patched _amfi_check_dyld_policy_self
[*] Sending SIGCONT to continue child
Hello World from iOS!
[*] Child exited with status 0
 [Info] [iOSOnMac] Runner_dist test completed
```

## iOS App Tree Example
```
tree main.app
main.app
├── Info.plist
├── _CodeSignature
│   └── CodeResources
└── main

2 directories, 3 files
```
## iOS Image Fuzzer Example
```
 ./runner imagefuzzer.app/imagefuzzer /mnt/fuzz/cve.png
[+] Child process created with pid: 68338
[*] Instrumenting process with PID 68338...
[*] Attempting to attach to task with PID 68338...
[+] Successfully attached to task with PID 68338
[*] Finding patch point...
[*] _amfi_check_dyld_policy_self at offset 0x6e728 in /usr/lib/dyld
[*] Attaching to target process...
[*] Scanning for /usr/lib/dyld in target's memory...
[*] /usr/lib/dyld mapped at 0x100c30000
[*] Patching _amfi_check_dyld_policy_self...
[+] Sucessfully patched _amfi_check_dyld_policy_self
[*] Sending SIGCONT to continue child
2023-11-26 15:09:56.573 ios6[68338:669986] Program started. Number of arguments: 2
2023-11-26 15:09:56.573 ios6[68338:669986] Argument 0: imagefuzzer.app/imagefuzzer
2023-11-26 15:09:56.573 ios6[68338:669986] Argument 1: /mnt/fuzz/cve.png
2023-11-26 15:09:56.573 ios6[68338:669986] Loading file from path: /mnt/fuzz/cve.png
2023-11-26 15:09:56.573 ios6[68338:669986] Data loaded from file: /mnt/fuzz/cve.png
2023-11-26 15:09:56.575 ios6[68338:669986] UIImage created: <UIImage:0x600002a854d0 anonymous {157, 157} renderingMode=automatic(original)>
2023-11-26 15:09:56.575 ios6[68338:669986] CGImage created from UIImage. Dimensions: 157 x 157
2023-11-26 15:09:56.575 ios6[68338:669986] RGB color space created.
2023-11-26 15:09:56.575 ios6[68338:669986] Creating bitmap context...
2023-11-26 15:09:56.575 ios6[68338:669986] Bitmap context created.
2023-11-26 15:09:56.575 ios6[68338:669986] Drawing image in bitmap context...
2023-11-26 15:09:56.576 ios6[68338:669986] Image drawn in bitmap context.
[*] Child exited with status 0
```
### Bug Sample
```
2023-11-26 16:30:47.386 imagefuzzer[93171:768680] Program started. Number of arguments: 2
2023-11-26 16:30:47.386 imagefuzzer[93171:768680] Argument 0: imagefuzzer.app/imagefuzzer
2023-11-26 16:30:47.386 imagefuzzer[93171:768680] Argument 1: imagefuzzer.app/img/bug.exr
2023-11-26 16:30:47.386 imagefuzzer[93171:768680] Loading file from path: imagefuzzer.app/img/bug.exr
2023-11-26 16:30:47.386 imagefuzzer[93171:768680] Data loaded from file: imagefuzzer.app/img/bug.exr
2023-11-26 16:30:47.388 imagefuzzer[93171:768680] UIImage created: <UIImage:0x60000005d290 anonymous {784, 734} renderingMode=automatic(original)>
2023-11-26 16:30:47.388 imagefuzzer[93171:768680] CGImage created from UIImage. Dimensions: 784 x 734
2023-11-26 16:30:47.388 imagefuzzer[93171:768680] RGB color space created.
2023-11-26 16:30:47.388 imagefuzzer[93171:768680] Creating bitmap context...
2023-11-26 16:30:47.388 imagefuzzer[93171:768680] Bitmap context created.
2023-11-26 16:30:47.388 imagefuzzer[93171:768680] Drawing image in bitmap context...
libc++abi: terminating due to uncaught exception of type int
```

### Testing arm64e 
#### hello.c | From Apple Security Research Device | SRT 20C80 | arm64e
My Repo https://github.com/xsscx/srd/tree/main/srd_tools-24.100.3/example-cryptex
```
xcrun -sdk iphoneos clang -arch arm64e -g interpose.c -o interpose.dylib -shared
xcrun -sdk iphoneos clang  -arch arm64e -g hello.c -o hello.app/hello interpose.dylib
codesign -s "ID" --entitlements entitlements.xml --force hello.app
./runner hello.app/hello
...
codesign -dvv hello.app/hello
Executable=/Users/xss/tmp/iOSOnMac/hello.app/hello
Identifier=cx.srd.hello
Format=bundle with Mach-O thin (arm64e)
CodeDirectory v=20400 size=752 flags=0x0(none) hashes=13+7 location=embedded
Sealed Resources version=2 rules=10 files=3
Internal requirements count=1 size=172
...
./runner hello.app/hello
[+] Child process created with pid: 42536
[*] Instrumenting process with PID 42536...
[*] Attempting to attach to task with PID 42536...
[+] Successfully attached to task with PID 42536
[*] Finding patch point...
[*] _amfi_check_dyld_policy_self at offset 0x6e728 in /usr/lib/dyld
[*] Attaching to target process...
[*] Scanning for /usr/lib/dyld in target's memory...
[*] /usr/lib/dyld mapped at 0x104970000
[*] Patching _amfi_check_dyld_policy_self...
[+] Sucessfully patched _amfi_check_dyld_policy_self
[*] Sending SIGCONT to continue child
Hello researcher from pid 42536!
[*] Child exited with status 0
```
### Simple-Server Example | From Apple Security Research Device | SRT 20C80 | arm64e
My Repo https://github.com/xsscx/srd/tree/main/srd_tools-24.100.3/example-cryptex
```
% export CRYPTEX_MOUNT_PATH=./
lldb -- ./runner simple-server.app/simple-server
(lldb) target create "./runner"
Current executable set to '/Users/xss/tmp/iOSOnMac/runner' (arm64).
(lldb) settings set -- target.run-args  "simple-server.app/simple-server"
(lldb) r
Process 28561 launched: '/Users/xss/tmp/iOSOnMac/runner' (arm64)
[+] Child process created with pid: 28565
[*] Instrumenting process with PID 28565...
[*] Attempting to attach to task with PID 28565...
[+] Successfully attached to task with PID 28565
[*] Finding patch point...
[*] _amfi_check_dyld_policy_self at offset 0x6e728 in /usr/lib/dyld
[*] Attaching to target process...
[*] Scanning for /usr/lib/dyld in target's memory...
[*] /usr/lib/dyld mapped at 0x100018000
[*] Patching _amfi_check_dyld_policy_self...
[+] Sucessfully patched _amfi_check_dyld_policy_self
[*] Sending SIGCONT to continue child
2023-11-25 10:00:38.526027-0500 simple-server[28565:155085] [simple-server] Hello! I'm simple-server from the example cryptex!
2023-11-25 10:00:38.526057-0500 simple-server[28565:155085] [simple-server] I'm about to bind to 0.0.0.0:7777
2023-11-25 10:00:38.526125-0500 simple-server[28565:155085] [simple-server] I'm about to listen on fd: 3
2023-11-25 10:00:38.526143-0500 simple-server[28565:155085] [simple-server] Waiting for a client to connect...
2023-11-25 10:00:43.143281-0500 simple-server[28565:155085] [simple-server] A client has connected!
2023-11-25 10:00:43.143323-0500 simple-server[28565:155085] [simple-server] Hello! I'm process 28565
2023-11-25 10:00:43.143363-0500 simple-server[28565:155085] [simple-server] Waiting for a client to connect...
```
#### Simple-Server Check | From Apple Security Research Device | SRT 20C80 | arm64e
My Repo https://github.com/xsscx/srd/tree/main/srd_tools-24.100.3/example-cryptex
```
% telnet 127.0.0.1 7777
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
Hello! I'm process 28668
The environment variable CRYPTEX_MOUNT_PATH  contains: "/Users/xss/Documents/iphone11/com.example.cryptex.dstroot/"
```
### Platform Checks
```
otool -l main.app/main | grep platform
 platform 2
otool -l hello.app/hello | grep platform
 platform 2
otool -l interpose.dylib | grep platform
 platform 2
otool -l runner | grep platform
 platform 1
otool -l test-platform6 | grep platform
 platform 6
```
### Plaform Identifiers
```
Platform 1: macOS
Platform 2: iOS
Platform 3: tvOS
Platform 4: watchOS
Platform 5: bridgeOS
Platform 6: iOS Simulator
Platform 7: tvOS Simulator
Platform 8: watchOS Simulator
```
## Fuzzing iOS on Mac
A sample image.app for the command line and introspection is provided. This can be expanded for Fuzzing native iOS Frameworks
```
./runner image.app/image
[+] Child process created with pid: 67178
[*] Instrumenting process with PID 67178...
[*] Attempting to attach to task with PID 67178...
[+] Successfully attached to task with PID 67178
[*] Finding patch point...
[*] _amfi_check_dyld_policy_self at offset 0x6e728 in /usr/lib/dyld
[*] Attaching to target process...
[*] Scanning for /usr/lib/dyld in target's memory...
[*] /usr/lib/dyld mapped at 0x100b44000
[*] Patching _amfi_check_dyld_policy_self...
[+] Sucessfully patched _amfi_check_dyld_policy_self
[*] Sending SIGCONT to continue child
2023-11-26 13:07:18.308 image[67178:613463] Image details - Width: 157, Height: 157
^C
```
### image.app details
```
% otool -L image.app/image
image.app/image:
	/System/Library/Frameworks/UIKit.framework/UIKit (compatibility version 1.0.0, current version 7082.1.111)
	/System/Library/Frameworks/Foundation.framework/Foundation (compatibility version 300.0.0, current version 2048.1.101)
	/System/Library/Frameworks/CoreGraphics.framework/CoreGraphics (compatibility version 64.0.0, current version 1774.0.1)
	interpose.dylib (compatibility version 0.0.0, current version 0.0.0)
	/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1336.0.0)
	/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation (compatibility version 150.0.0, current version 2048.1.101)
	/usr/lib/libobjc.A.dylib (compatibility version 1.0.0, current version 228.0.0)

% otool -l image.app/image | grep platform
 platform 2

% tree image.app
image.app
├── Info.plist
├── _CodeSignature
│   └── CodeResources
├── demo.png
└── image

2 directories, 4 files

%  codesign -dvvv image.app
Executable=/Users/xss/tmp/iOSOnMac/image.app/image
Identifier=cx.srd.image-demo
Format=bundle with Mach-O thin (arm64)
CodeDirectory v=20400 size=757 flags=0x0(none) hashes=13+7 location=embedded
Hash type=sha256 size=32
CandidateCDHash sha256=2169d9bcfa6d8b5c1493b96d5862a408e07231a2
CandidateCDHashFull sha256=2169d9bcfa6d8b5c1493b96d5862a408e07231a2f600600d1c4cc6ec5b69f4bb
Hash choices=sha256
CMSDigest=2169d9bcfa6d8b5c1493b96d5862a408e07231a2f600600d1c4cc6ec5b69f4bb
CMSDigestType=2
CDHash=2169d9bcfa6d8b5c1493b96d5862a408e07231a2
Signature size=8970
Authority=Developer ID Application: David Hoyt (7KJ5XYCA8X)
Authority=Developer ID Certification Authority
Authority=Apple Root CA
Timestamp=Nov 26, 2023 at 13:06:20
Info.plist entries=2
TeamIdentifier=7KJ5XYCA8X
Sealed Resources version=2 rules=10 files=2
Internal requirements count=1 size=180

% file image.app/image
image.app/image: Mach-O 64-bit executable arm64
```

### exr-loader.app example
```
 ./runner exr-loader.app/exr-loader
[+] Child process created with pid: 67855
[*] Instrumenting process with PID 67855...
[*] Attempting to attach to task with PID 67855...
[+] Successfully attached to task with PID 67855
[*] Finding patch point...
[*] _amfi_check_dyld_policy_self at offset 0x6e728 in /usr/lib/dyld
[*] Attaching to target process...
[*] Scanning for /usr/lib/dyld in target's memory...
[*] /usr/lib/dyld mapped at 0x100300000
[*] Patching _amfi_check_dyld_policy_self...
[+] Sucessfully patched _amfi_check_dyld_policy_self
[*] Sending SIGCONT to continue child
2023-11-26 14:33:37.773 img2[67855:652901] Image details - Width: 784, Height: 734
2023-11-26 14:33:37.773 img2[67855:652901] Creating bitmap context...
2023-11-26 14:33:37.773 img2[67855:652901] Bitmap context created.
2023-11-26 14:33:37.773 img2[67855:652901] Drawing image in bitmap context...
2023-11-26 14:33:37.777 img2[67855:652901] Image drawn in bitmap context.
```
