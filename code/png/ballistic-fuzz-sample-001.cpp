// Written by @h023332
// Quick Fuzzing Loops for libpng, pngwriter, ImageMagick and others
// This .cpp targets a quick check to ImageMagick
// Compile with Instrumentation
// clang++ -fprofile-instr-generate -fcoverage-mapping -mllvm -runtime-counter-relocation -g -fsanitize=undefined -O0 -o ball-fuzz19 ball-fuzz19.cpp -std=c++11 `Magick++-config --cppflags --cxxflags --ldflags --libs`
//
//
// Compile with attached zsh script

#include <Magick++.h>
#include <ctime>
#include <sstream>
#include <iostream>
#include <fstream>
#include <sys/stat.h>
#include <cstdlib>
#include <random>

const int MAX_ITERATIONS = 6000000;
const int MAX_RETRIES = 5;

std::random_device rd;
std::mt19937 gen(rd());

void log(const std::string &message) {
    std::ofstream logFile("fuzz_log.txt", std::ios_base::app);
    logFile << message << std::endl;
}

int getRandomValue(int min, int max) {
    std::uniform_int_distribution<> dis(min, max);
    return dis(gen);
}

void ballistic(Magick::Image &image, int maxIter, int depositionSize) {
    int width = image.columns();
    int height = image.rows();

    Magick::Color red(65535, 0, 0);

    image.strokeColor(red);
    image.draw(Magick::DrawableLine(width / 2.0 - depositionSize / 2.0, 1, width / 2.0 + depositionSize / 2.0, 1));

    for (int iii = 0; iii < maxIter; iii++) {
        int rr = rand() % width;
        for (int rrr = height - 1; rrr > 0; rrr--) {
            if (image.pixelColor(rr, rrr) == red) {
                if ((image.pixelColor(rr - 1, rrr) == red) ||
                    (image.pixelColor(rr + 1, rrr) == red) ||
                    (image.pixelColor(rr, rrr - 1) == red)) {
                    image.pixelColor(rr, rrr, red);
                    break;
                }
            }
        }
    }
}

// Introduce more manipulation techniques
void applyManipulations(Magick::Image &image) {
    int choice = rand() % 5;
    switch (choice) {
        case 0:
            image.flip();
            break;
        case 1:
            image.flop();
            break;
        case 2:
            image.rotate(90.0);
            break;
        case 3:
            image.negate();
            break;
        case 4:
            image.blur(0.5, 2.0);
            break;
        default:
            break;
    }
}

std::string getRandomImageType() {
    std::vector<std::string> imageTypes = {"png", "jpeg", "gif", "tiff", "bmp"};
    int index = rand() % imageTypes.size();
    return imageTypes[index];
}

int main(int argc, char **argv) {
    Magick::InitializeMagick(*argv);

    srand(time(NULL));
    const int NUM_IMAGES = 10;

    // Create directory for output images
    std::time_t t = std::time(nullptr);
    char dirNameCStr[100];
    strftime(dirNameCStr, sizeof(dirNameCStr), "fuzzing_%Y%m%d%H%M%S", std::localtime(&t));
    std::string dirName = dirNameCStr;
    mkdir(dirName.c_str(), 0777);

    for (int i = 0; i < NUM_IMAGES; i++) {
        int width = 300 + (rand() % 1200);
        int height = 300 + (rand() % 1200);
        int bitDepth = (rand() % 3) ? 8 : ((rand() % 2 == 0) ? 16 : 32); // Added option for 32 bit depth
        int depositionSize = 10 + (rand() % (width / 2));
        int maxIter = (rand() % MAX_ITERATIONS);

        std::string imageType = getRandomImageType();
        std::stringstream filename;
        filename << dirName << "/ballistic_" << i << "." << imageType;

        int retries = MAX_RETRIES;
        while (retries--) {
            try {
                Magick::Image image(Magick::Geometry(width, height), Magick::Color(0, 0, 0));
                image.depth(bitDepth);

                // Varying the Ballistic Deposition parameters
                ballistic(image, maxIter, depositionSize);

                // Apply the introduced manipulations
                applyManipulations(image);

                if (image.type() == Magick::PaletteType && !image.isValid()) {
                    std::cerr << "Image is of PaletteType but lacks a valid palette. Skipping." << std::endl;
                } else {
                    std::stringstream logMsgBeforeWrite;
                    logMsgBeforeWrite << "Attempting to write image: " << filename.str() << " with dimensions: " << width << "x" << height << ", bit depth: " << bitDepth << ", deposition size: " << depositionSize << ", max iterations: " << maxIter;
                    log(logMsgBeforeWrite.str());

                    image.write(filename.str());
                }

                std::stringstream logMsg;
                logMsg << "Generated image: " << filename.str() << " with dimensions: " << width << "x" << height << ", bit depth: " << bitDepth << ", deposition size: " << depositionSize << ", max iterations: " << maxIter;
                log(logMsg.str());
                std::cout << logMsg.str() << std::endl;

                // If success, break out of the retry loop
                break;

            } catch (Magick::Exception &error) {
                std::cerr << "Caught ImageMagick exception: " << error.what() << std::endl;
                continue; // Retry with new random parameters
            } catch (std::exception &e) {
                std::cerr << "Caught standard exception: " << e.what() << std::endl;
                break;
            }
        }
    }

    return 0;
}
