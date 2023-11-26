# iOSOnMac 
- See URL https://github.com/googleprojectzero/p0tools/tree/master/iOSOnMac
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
![iosonmac-example-build-run](https://github.com/xsscx/macos-research/assets/10790582/9d7ca4c4-594c-4423-a798-987bbb91d49e)

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

## Testing with Example Code
```
/runner main.app/main
[+] Child process created with pid: 42525
[*] Instrumenting process with PID 42525...
[*] Attempting to attach to task with PID 42525...
[+] Successfully attached to task with PID 42525
[*] Finding patch point...
[*] _amfi_check_dyld_policy_self at offset 0x6e728 in /usr/lib/dyld
[*] Attaching to target process...
[*] Scanning for /usr/lib/dyld in target's memory...
[*] /usr/lib/dyld mapped at 0x104348000
[*] Patching _amfi_check_dyld_policy_self...
[+] Sucessfully patched _amfi_check_dyld_policy_self
[*] Sending SIGCONT to continue child
Hello World from iOS!
[*] Child exited with status 0
```

### Testing arm64e 
#### arm64e Build Example
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
### Simple-Server Example | 20C80
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
#### Simple-Server Check | 20C80 Example
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
