// @h02332 DHoyt - written to demo using iOSOnMac and interposing iOS apps on macOS.
// xcrun -sdk iphoneos clang++ -arch arm64 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS17.0.sdk -framework UIKit -framework Foundation -framework CoreGraphics -miphoneos-version-min=12.0 -o imagefuzzer ios-image-fuzzer-example.mm interpose.dylib
// ./runner imgfuzzer.app/imgfuzzer /mnt/fuzzing/img/cve.png
//
#include <Foundation/Foundation.h>
#include <UIKit/UIKit.h>
#include <iostream>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSLog(@"Program started. Number of arguments: %d", argc);

        for (int i = 0; i < argc; ++i) {
            NSLog(@"Argument %d: %s", i, argv[i]);
        }

        if (argc < 2) {
            NSLog(@"Usage: %s path/to/image", argv[0]);
            return 0;
        }

        NSString* path = [NSString stringWithUTF8String:argv[1]];
        NSLog(@"Loading file from path: %@", path);

        NSData* content = [NSData dataWithContentsOfFile:path];
        if (!content) {
            NSLog(@"Failed to load data from file: %@", path);
            return 1;
        }
        NSLog(@"Data loaded from file: %@", path);

        UIImage* img = [[UIImage alloc] initWithData:content];
        if (!img) {
            NSLog(@"Failed to create UIImage from data.");
            return 1;
        }
        NSLog(@"UIImage created: %@", img);

        CGImageRef cgImg = [img CGImage];
        if (!cgImg) {
            NSLog(@"Failed to get CGImage from UIImage.");
            return 1;
        }
        NSLog(@"CGImage created from UIImage. Dimensions: %zu x %zu", CGImageGetWidth(cgImg), CGImageGetHeight(cgImg));

        CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
        if (!colorspace) {
            NSLog(@"Failed to create RGB color space.");
            CGImageRelease(cgImg);
            return 1;
        }
        NSLog(@"RGB color space created.");

        // Try-catch block to catch and log C++ exceptions
        try {
            NSLog(@"Creating bitmap context...");
            CGContextRef ctx = CGBitmapContextCreate(NULL, CGImageGetWidth(cgImg), CGImageGetHeight(cgImg), 8, 0, colorspace, kCGImageAlphaNoneSkipFirst);
            if (!ctx) {
                NSLog(@"Failed to create bitmap context.");
                CGColorSpaceRelease(colorspace);
                CGImageRelease(cgImg);
                return 1;
            }
            NSLog(@"Bitmap context created.");

            CGRect rect = CGRectMake(0, 0, CGImageGetWidth(cgImg), CGImageGetHeight(cgImg));
            NSLog(@"Drawing image in bitmap context...");
            CGContextDrawImage(ctx, rect, cgImg);
            NSLog(@"Image drawn in bitmap context.");

            CGContextRelease(ctx);
            CGColorSpaceRelease(colorspace);
            CGImageRelease(cgImg);

        } catch (const std::exception& e) {
            std::cerr << "Caught C++ exception in image processing: " << e.what() << std::endl;
            return 1;
        }
    }

    return 0;
}

