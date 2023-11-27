// @h02332 DHoyt - written to demo using iOSOnMac and interposing iOS apps on macOS.
// xcrun -sdk iphoneos clang++ -arch arm64 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS17.0.sdk -framework UIKit -framework Foundation -framework CoreGraphics -miphoneos-version-min=12.0 -o imagefuzzer ios-image-fuzzer-example.mm interpose.dylib
// ./runner imgfuzzer.app/imgfuzzer /mnt/fuzzing/img/cve.png 1
//
#include <Foundation/Foundation.h>
#include <UIKit/UIKit.h>
#include <iostream>

// Function declarations
BOOL isValidImagePath(NSString *path);
UIImage *loadImageFromFile(NSString *path);
void processImage(UIImage *image, int permutation);

// Permutation functions
void createBitmapContextStandardRGB(CGImageRef cgImg);
void createBitmapContextPremultipliedFirstAlpha(CGImageRef cgImg);
void createBitmapContextNonPremultipliedAlpha(CGImageRef cgImg);
void createBitmapContext16BitDepth(CGImageRef cgImg);
void createBitmapContextGrayscale(CGImageRef cgImg);
void createBitmapContextHDRFloatComponents(CGImageRef cgImg);
void createBitmapContextAlphaOnly(CGImageRef cgImg);
void createBitmapContext1BitMonochrome(CGImageRef cgImg);
void createBitmapContextBigEndian(CGImageRef cgImg);
void createBitmapContextLittleEndian(CGImageRef cgImg);
void createBitmapContext8BitInvertedColors(CGImageRef cgImg);
void createBitmapContext32BitFloat4Component(CGImageRef cgImg);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc < 3) {
            NSLog(@"Usage: %s path/to/image permutation_number", argv[0]);
            return 0;
        }

        NSString* imagePath = [NSString stringWithUTF8String:argv[1]];
        int permutation = atoi(argv[2]);

        if (!isValidImagePath(imagePath)) {
            NSLog(@"Invalid image path: %@", imagePath);
            return 1;
        }

        UIImage *image = loadImageFromFile(imagePath);
        if (!image) {
            NSLog(@"Failed to load image from file: %@", imagePath);
            return 1;
        }

        processImage(image, permutation);
    }

    return 0;
}

BOOL isValidImagePath(NSString *path) {
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
    NSLog(fileExists ? @"Valid image path: %@" : @"Invalid image path: %@", path);
    return fileExists;
}

UIImage *loadImageFromFile(NSString *path) {
    NSLog(@"Loading file from path: %@", path);
    NSData *content = [NSData dataWithContentsOfFile:path];
    if (!content) {
        NSLog(@"Failed to load data from file: %@", path);
        return nil;
    }
    NSLog(@"Data loaded from file: %@", path);

    UIImage *image = [[UIImage alloc] initWithData:content];
    if (!image) {
        NSLog(@"Failed to create UIImage from data.");
        return nil;
    }
    NSLog(@"UIImage created: %@", image);
    return image;
}

void processImage(UIImage *image, int permutation) {
    CGImageRef cgImg = [image CGImage];
    if (!cgImg) {
        NSLog(@"Failed to get CGImage from UIImage.");
        return;
    }
    NSLog(@"CGImage created from UIImage. Dimensions: %zu x %zu", CGImageGetWidth(cgImg), CGImageGetHeight(cgImg));
    
    switch (permutation) {
        case 1:
            NSLog(@"Case: Creating bitmap context with Standard RGB settings");
            createBitmapContextStandardRGB(cgImg);
            break;
        case 2:
            NSLog(@"Case: Creating bitmap context with Premultiplied First Alpha settings");
            createBitmapContextPremultipliedFirstAlpha(cgImg);
            break;
        case 3:
            NSLog(@"Case: Creating bitmap context with Non-Premultiplied Alpha settings");
            createBitmapContextNonPremultipliedAlpha(cgImg);
            break;
        case 4:
            NSLog(@"Case: Creating bitmap context with 16-bit depth settings");
            createBitmapContext16BitDepth(cgImg);
            break;
        case 5:
            NSLog(@"Case: Creating bitmap context with Grayscale settings");
            createBitmapContextGrayscale(cgImg);
            break;
        case 6:
            NSLog(@"Case: Creating bitmap context with HDR Float Components settings");
            createBitmapContextHDRFloatComponents(cgImg);
            break;
        case 7:
            NSLog(@"Case: Creating bitmap context with Alpha Only settings");
            createBitmapContextAlphaOnly(cgImg);
            break;
        case 8:
            NSLog(@"Case: Creating bitmap context with 1-bit Monochrome settings");
            createBitmapContext1BitMonochrome(cgImg);
            break;
        case 9:
            NSLog(@"Case: Creating bitmap context with Big Endian pixel format settings");
            createBitmapContextBigEndian(cgImg);
            break;
        case 10:
            NSLog(@"Case: Creating bitmap context with Little Endian pixel format settings");
            createBitmapContextLittleEndian(cgImg);
            break;
        case 11:
            NSLog(@"Case: Creating bitmap context with 8-bit depth, inverted colors settings");
            createBitmapContext8BitInvertedColors(cgImg);
            break;
        case 12:
            NSLog(@"Case: Creating bitmap context with 32-bit float, 4-component settings");
            createBitmapContext32BitFloat4Component(cgImg);
            break;
        default:
            NSLog(@"Case: Invalid permutation number %d", permutation);
            break;
    }

    NSLog(@"Completed image processing for permutation %d", permutation);
}

void createBitmapContextStandardRGB(CGImageRef cgImg) {
    NSLog(@"Creating bitmap context with Standard RGB settings");
    size_t width = CGImageGetWidth(cgImg);
    size_t height = CGImageGetHeight(cgImg);
    CGContextRef ctx = CGBitmapContextCreate(NULL, width, height, 8, width * 4, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaNoneSkipFirst);
    if (!ctx) {
        NSLog(@"Failed to create bitmap context with Standard RGB settings");
        return;
    }
    NSLog(@"Bitmap context with Standard RGB settings created successfully");
    CGContextRelease(ctx);
}

void createBitmapContextPremultipliedFirstAlpha(CGImageRef cgImg) {
    NSLog(@"Creating bitmap context with Premultiplied First Alpha settings");
    size_t width = CGImageGetWidth(cgImg);
    size_t height = CGImageGetHeight(cgImg);
    CGContextRef ctx = CGBitmapContextCreate(NULL, width, height, 8, width * 4, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedFirst);
    if (!ctx) {
        NSLog(@"Failed to create bitmap context with Premultiplied First Alpha settings");
        return;
    }
    NSLog(@"Bitmap context with Premultiplied First Alpha settings created successfully");
    CGContextRelease(ctx);
}

void createBitmapContextNonPremultipliedAlpha(CGImageRef cgImg) {
    NSLog(@"Creating bitmap context with Non-Premultiplied Alpha settings");
    size_t width = CGImageGetWidth(cgImg);
    size_t height = CGImageGetHeight(cgImg);
    CGContextRef ctx = CGBitmapContextCreate(NULL, width, height, 8, width * 4, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaLast);
    if (!ctx) {
        NSLog(@"Failed to create bitmap context with Non-Premultiplied Alpha settings");
        return;
    }
    NSLog(@"Bitmap context with Non-Premultiplied Alpha settings created successfully");
    CGContextRelease(ctx);
}

void createBitmapContext16BitDepth(CGImageRef cgImg) {
    NSLog(@"Creating bitmap context with 16-bit Depth settings");
    size_t width = CGImageGetWidth(cgImg);
    size_t height = CGImageGetHeight(cgImg);
    CGContextRef ctx = CGBitmapContextCreate(NULL, width, height, 16, width * 8, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedFirst);
    if (!ctx) {
        NSLog(@"Failed to create bitmap context with 16-bit Depth settings");
        return;
    }
    NSLog(@"Bitmap context with 16-bit Depth settings created successfully");
    CGContextRelease(ctx);
}

void createBitmapContextGrayscale(CGImageRef cgImg) {
    NSLog(@"Creating bitmap context with Grayscale settings");
    size_t width = CGImageGetWidth(cgImg);
    size_t height = CGImageGetHeight(cgImg);
    CGColorSpaceRef graySpace = CGColorSpaceCreateDeviceGray();
    CGContextRef ctx = CGBitmapContextCreate(NULL, width, height, 8, width, graySpace, kCGImageAlphaNone);
    if (!ctx) {
        NSLog(@"Failed to create bitmap context with Grayscale settings");
        CGColorSpaceRelease(graySpace);
        return;
    }
    NSLog(@"Bitmap context with Grayscale settings created successfully");
    CGContextRelease(ctx);
    CGColorSpaceRelease(graySpace);
}

void createBitmapContextHDRFloatComponents(CGImageRef cgImg) {
    NSLog(@"Creating bitmap context with HDR Float Components settings");
    size_t width = CGImageGetWidth(cgImg);
    size_t height = CGImageGetHeight(cgImg);
    CGContextRef ctx = CGBitmapContextCreate(NULL, width, height, 32, width * 16, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast | kCGBitmapFloatComponents);
    if (!ctx) {
        NSLog(@"Failed to create bitmap context with HDR Float Components settings");
        return;
    }
    NSLog(@"Bitmap context with HDR Float Components settings created successfully");
    CGContextRelease(ctx);
}

void createBitmapContextAlphaOnly(CGImageRef cgImg) {
    NSLog(@"Creating bitmap context with Alpha Only settings");
    size_t width = CGImageGetWidth(cgImg);
    size_t height = CGImageGetHeight(cgImg);
    CGContextRef ctx = CGBitmapContextCreate(NULL, width, height, 8, width, NULL, kCGImageAlphaOnly);
    if (!ctx) {
        NSLog(@"Failed to create bitmap context with Alpha Only settings");
        return;
    }
    NSLog(@"Bitmap context with Alpha Only settings created successfully");
    CGContextRelease(ctx);
}

void createBitmapContext1BitMonochrome(CGImageRef cgImg) {
    NSLog(@"Creating bitmap context with 1-bit Monochrome settings");
    size_t width = CGImageGetWidth(cgImg);
    size_t height = CGImageGetHeight(cgImg);
    CGContextRef ctx = CGBitmapContextCreate(NULL, width, height, 1, width / 8, NULL, kCGImageAlphaNone);
    if (!ctx) {
        NSLog(@"Failed to create bitmap context with 1-bit Monochrome settings");
        return;
    }
    NSLog(@"Bitmap context with 1-bit Monochrome settings created successfully");
    CGContextRelease(ctx);
}

void createBitmapContextBigEndian(CGImageRef cgImg) {
    NSLog(@"Creating bitmap context with Big Endian settings");
    size_t width = CGImageGetWidth(cgImg);
    size_t height = CGImageGetHeight(cgImg);
    CGContextRef ctx = CGBitmapContextCreate(NULL, width, height, 8, width * 4, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    if (!ctx) {
        NSLog(@"Failed to create bitmap context with Big Endian settings");
        return;
    }
    NSLog(@"Bitmap context with Big Endian settings created successfully");
    CGContextRelease(ctx);
}

void createBitmapContextLittleEndian(CGImageRef cgImg) {
    NSLog(@"Creating bitmap context with Little Endian settings");
    size_t width = CGImageGetWidth(cgImg);
    size_t height = CGImageGetHeight(cgImg);
    CGContextRef ctx = CGBitmapContextCreate(NULL, width, height, 8, width * 4, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little);
    if (!ctx) {
        NSLog(@"Failed to create bitmap context with Little Endian settings");
        return;
    }
    NSLog(@"Bitmap context with Little Endian settings created successfully");
    CGContextRelease(ctx);
}

void createBitmapContext8BitInvertedColors(CGImageRef cgImg) {
    NSLog(@"Creating bitmap context with 8-bit depth, inverted colors");
    size_t width = CGImageGetWidth(cgImg);
    size_t height = CGImageGetHeight(cgImg);
    CGContextRef ctx = CGBitmapContextCreate(NULL, width, height, 8, width * 4, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Little);
    if (!ctx) {
        NSLog(@"Failed to create bitmap context with 8-bit depth, inverted colors");
        return;
    }
    // Additional processing
    NSLog(@"Bitmap context with 8-bit depth, inverted colors created successfully");
    CGContextRelease(ctx);
}

void createBitmapContext32BitFloat4Component(CGImageRef cgImg) {
    NSLog(@"Creating bitmap context with 32-bit float, 4-component settings");
    size_t width = CGImageGetWidth(cgImg);
    size_t height = CGImageGetHeight(cgImg);
    CGContextRef ctx = CGBitmapContextCreate(NULL, width, height, 32, width * 16, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast | kCGBitmapFloatComponents);
    if (!ctx) {
        NSLog(@"Failed to create bitmap context with 32-bit float, 4-component settings");
        return;
    }
    // Additional processing
    NSLog(@"Bitmap context with 32-bit float, 4-component settings created successfully");
    CGContextRelease(ctx);
}
