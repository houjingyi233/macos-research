// Original Code Released by Google Project Zero at URL https://github.com/googleprojectzero/Jackalope/blob/main/examples/ImageIO/imageio.m
//
// Changes made by @h02332 to streamline fuzzing on native macOS X86_64 and arm64e and cleaned up the use of autorelease pool, which you can try commenting out too....
//
//

#include <Foundation/Foundation.h>
#include <Foundation/NSURL.h>
#include <dlfcn.h>
#include <stdint.h>
#include <sys/shm.h>
#include <dirent.h>
#include <sys/resource.h>
#include <stdarg.h> // For va_list, va_start, va_end

#import <ImageIO/ImageIO.h>
#import <AppKit/AppKit.h>
#import <CoreGraphics/CoreGraphics.h>

#define MAX_SAMPLE_SIZE 1000000
#define SHM_SIZE (4 + MAX_SAMPLE_SIZE)
unsigned char *shm_data;

bool use_shared_memory;

// Improved logging function
void log_info(const char *format, ...) {
    va_list args;
    va_start(args, format);
    vprintf(format, args);
    va_end(args);
    printf("\n"); // Ensure each log entry is on a new line
}

int setup_shmem(const char *name)
{
    int fd;

    fd = shm_open(name, O_RDONLY, S_IRUSR | S_IWUSR);
    if (fd == -1)
    {
        log_info("Error in shm_open");
        return 0;
    }

    shm_data = (unsigned char *)mmap(NULL, SHM_SIZE, PROT_READ, MAP_SHARED, fd, 0);
    if (shm_data == MAP_FAILED)
    {
        log_info("Error in mmap");
        return 0;
    }

    return 1;
}

#define FUZZ_TARGET_MODIFIERS __attribute__ ((noinline))

void dummyLogProc() { }

extern void ImageIOSetLoggingProc(void*);

CGContextRef ctx;

void FUZZ_TARGET_MODIFIERS fuzz(char *name) {
    @autoreleasepool {
        NSImage* img = NULL;
        char *sample_bytes = NULL;
        uint32_t sample_size = 0;

        if(use_shared_memory) {
            sample_size = *(uint32_t *)(shm_data);
            if(sample_size > MAX_SAMPLE_SIZE) sample_size = MAX_SAMPLE_SIZE;
            sample_bytes = (char *)malloc(sample_size);
            if (!sample_bytes) {
                log_info("Failed to allocate memory for sample_bytes");
                return;
            }
            memcpy(sample_bytes, shm_data + sizeof(uint32_t), sample_size);
            
            if (rand() % 10 == 0) {
                int error_pos = rand() % sample_size;
                sample_bytes[error_pos] = rand() % 256;
            }

            img = [[NSImage alloc] initWithData:[NSData dataWithBytes:sample_bytes length:sample_size]];
            free(sample_bytes);
        } else {
            img = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithUTF8String:name]];
        }

        if(!img) {
            log_info("Failed to load image from %s.", name);
            return;
        }

        CGImageRef cgImg = [img CGImageForProposedRect:nil context:nil hints:nil];
        if (cgImg) {
            size_t width = CGImageGetWidth(cgImg);
            size_t height = CGImageGetHeight(cgImg);
            log_info("Processing image %s: Width: %lu, Height: %lu", name, width, height);
            CGRect rect = CGRectMake(0, 0, width / (1 + (rand() % 3)), height / (1 + (rand() % 3)));
            CGContextDrawImage(ctx, rect, cgImg);
            CGImageRelease(cgImg);
        } else {
            log_info("CGImage creation failed for %s", name);
        }
    }
}

const char* supported_extensions[] = {
    ".jpg", ".jpeg", ".png", ".gif", ".bmp", ".heic", ".tiff", ".jp2",
    ".webp", ".icns", ".pict", ".sgi", ".tga", ".exr", ".hdr", ".pdf", ".raw", ".pvr", NULL
};

bool has_supported_extension(const char* filename) {
    const char* ext = strrchr(filename, '.');
    if (!ext) {
        return false;
    }

    for (int i = 0; supported_extensions[i] != NULL; i++) {
        if (strcasecmp(ext, supported_extensions[i]) == 0) {
            return true;
        }
    }

    return false;
}

int main(int argc, char **argv)
{
    if(argc != 3) {
        log_info("Usage: %s <-f|-m> <file or shared memory name>", argv[0]);
        return 0;
    }

    use_shared_memory = !strcmp(argv[1], "-m");

    if(use_shared_memory) {
        if(!setup_shmem(argv[2])) {
            log_info("Error mapping shared memory");
            return 1;
        }
    }

    ImageIOSetLoggingProc(&dummyLogProc);
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    ctx = CGBitmapContextCreate(0, 32, 32, 8, 0, colorspace, 1);

    if (!use_shared_memory) {
        DIR* dir = opendir(argv[2]);
        if (!dir) {
            log_info("Error opening directory: %s", argv[2]);
            return 1;
        }

        struct dirent* entry;
        while ((entry = readdir(dir)) != NULL) {
            if (entry->d_type == DT_REG) {
                if (has_supported_extension(entry->d_name)) {
                    char full_path[PATH_MAX];
                    snprintf(full_path, sizeof(full_path), "%s/%s", argv[2], entry->d_name);
                    fuzz(full_path);
                }
            }
        }
        closedir(dir);
    } else {
        fuzz(argv[2]);
    }

    CGContextRelease(ctx);
    CGColorSpaceRelease(colorspace);

    return 0;
}
