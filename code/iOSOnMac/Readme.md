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
 [---] Cleaning iOSOnMac
rm -rf runner runner_dist interpose.dylib main.app

% make
 [++] Building iOSOnMac
clang -o runner runner.c
codesign -s "79744B7FFC78720777469A82065993CA962BC8E8" --entitlements entitlements.xml --force runner
runner: replacing existing signature
 [++] Building iOSOnMac
clang -o runner_dist runner_dist.c
codesign -s "79744B7FFC78720777469A82065993CA962BC8E8" --entitlements entitlements.xml --force runner_dist
runner_dist: replacing existing signature
 [++] Building iOSOnMac
xcrun -sdk iphoneos clang -arch arm64   -g   -o interpose.dylib -shared interpose.c
 [++] Building iOSOnMac
xcrun -sdk iphoneos clang -arch arm64   -g   -o main main.c interpose.dylib
[2023-11-26 10:01:36] [iOSOnMac] -  Creating main.app...
mkdir -p main.app
cp Info.plist main.app/
mv main main.app/
[2023-11-26 10:01:36] [iOSOnMac] -  Created main.app... Codesigning....
codesign -s "79744B7FFC78720777469A82065993CA962BC8E8" --entitlements entitlements.xml --force main.app

% ./runner main.app/main
[+] Child process created with pid: 62142
[*] Instrumenting process with PID 62142...
[*] Attempting to attach to task with PID 62142...
[+] Successfully attached to task with PID 62142
[*] Finding patch point...
[*] _amfi_check_dyld_policy_self at offset 0x6e728 in /usr/lib/dyld
[*] Attaching to target process...
[*] Scanning for /usr/lib/dyld in target's memory...
[*] /usr/lib/dyld mapped at 0x100e64000
[*] Patching _amfi_check_dyld_policy_self...
[+] Sucessfully patched _amfi_check_dyld_policy_self
[*] Sending SIGCONT to continue child
Hello World from iOS!
[*] Child exited with status 0

% ./runner_dist main.app/main
[*] Preparing to execute iOS binary main.app/main
[+] Child process created with pid: 62153
[*] Patching child process to allow dyld interposing...
[*] _amfi_check_dyld_policy_self at offset 0x6e728 in /usr/lib/dyld
[*] /usr/lib/dyld mapped at 0x100794000
[+] Sucessfully patched _amfi_check_dyld_policy_self
[*] Sending SIGCONT to continue child
Hello World from iOS!
[*] Child exited with status 0
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

### Testing arm64e 
#### hello.c | From Apple Security Research Device | SRT 20C80 | arm64e
```
xcrun -sdk iphoneos clang -arch arm64e -g interpose.c -o interpose.dylib -shared
xcrun -sdk iphoneos clang  -arch arm64e -g hello.c -o hello.app/hello interpose.dylib
codesign -s "ID" --entitlements entitlements.xml --force hello.app
./runner hello.app/hello

[+] Child process created with pid: 48331
[*] Instrumenting process with PID 48331...
[*] Attempting to attach to task with PID 48331...
[+] Successfully attached to task with PID 48331
[*] Finding patch point...
[*] _amfi_check_dyld_policy_self at offset 0x6e728 in /usr/lib/dyld
[*] Attaching to target process...
[*] Scanning for /usr/lib/dyld in target's memory...
[*] /usr/lib/dyld mapped at 0x1025e8000
[*] Patching _amfi_check_dyld_policy_self...
[+] Sucessfully patched _amfi_check_dyld_policy_self
[*] Sending SIGCONT to continue child
Hello from an iOS binary!
[*] Child exited with status 0
codesign -dvv hello.app/hello
Executable=/Users/xss/tmp/iOSOnMac/hello.app/hello
Identifier=cx.srd.hello
Format=bundle with Mach-O thin (arm64e)
CodeDirectory v=20400 size=752 flags=0x0(none) hashes=13+7 location=embedded
...
Sealed Resources version=2 rules=10 files=3
Internal requirements count=1 size=172
```
```
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
```
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
```
telnet 127.0.0.1 7777
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
Hello! I'm process 28668
The environment variable CRYPTEX_MOUNT_PATH  contains: "/Users/xss/Documents/iphone11/com.example.cryptex.dstroot/usr/bin/sh"
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
