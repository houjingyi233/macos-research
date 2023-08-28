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
#include <vector>
#include <string>

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

void applyManipulations(Magick::Image &image) {
    int choice = getRandomValue(0, 4);  // Adjusted to use getRandomValue
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
    return imageTypes[getRandomValue(0, imageTypes.size() - 1)];
}

void ballistic(Magick::Image &image, int currentMaxIter, int currentDepositionSize) {
    int width = 300 + getRandomValue(0, 1200);
    int height = 300 + getRandomValue(0, 1200);
    int bitDepth = (getRandomValue(0, 1) == 0) ? 8 : 16;

    // Randomize the color
    Magick::Color particleColor(getRandomValue(0, 65535), getRandomValue(0, 65535), getRandomValue(0, 65535));
    image.strokeColor(particleColor);

    // Create a larger seed line to ensure visibility
    currentDepositionSize = std::min(currentDepositionSize, width - 10);
    image.draw(Magick::DrawableLine(width / 2.0 - currentDepositionSize / 2.0, height / 2.0, width / 2.0 + currentDepositionSize / 2.0, height / 2.0));

    for (int iii = 0; iii < currentMaxIter; iii++) {
        int rr = getRandomValue(0, width - 1);
        for (int rrr = height - 1; rrr > 0; rrr--) {
            if (image.pixelColor(rr, rrr) == particleColor) {
                if ((image.pixelColor(rr - 1, rrr) == particleColor) ||
                    (image.pixelColor(rr + 1, rrr) == particleColor) ||
                    (image.pixelColor(rr, rrr - 1) == particleColor)) {
                    image.pixelColor(rr, rrr, particleColor);
                    break;
                }
            }
        }
    }
}

int main(int argc, char **argv) {
    // Initialize ImageMagick's graphics system
    Magick::InitializeMagick(*argv);

    const int NUM_IMAGES = 10;  // Or adjust this as per your requirements.

    for (int i = 0; i < NUM_IMAGES; i++) {
        int width = 300 + getRandomValue(0, 1200);
        int height = 300 + getRandomValue(0, 1200);
        int bitDepth = (getRandomValue(0, 1) == 0) ? 8 : 16;

        int currentDepositionSize = 50 + getRandomValue(0, width / 2);
        int currentMaxIter = MAX_ITERATIONS + getRandomValue(0, 4000);

        // Create an image object and set size, background, and depth
        Magick::Image image(Magick::Geometry(width, height), Magick::Color("white"));
        image.depth(bitDepth);

        // Here you can construct the filename for the image as you were doing
        std::stringstream filename;
        filename << "output_image_" << i << "." << getRandomImageType();  // Changed the filename to use getRandomImageType()

        ballistic(image, currentMaxIter, currentDepositionSize);
        applyManipulations(image);  // Apply random image manipulations

        std::stringstream logMsgBeforeWrite;
        logMsgBeforeWrite << "Attempting to write image: " << filename.str()
                          << " with dimensions: " << width << "x" << height
                          << ", bit depth: " << bitDepth
                          << ", deposition size: " << currentDepositionSize
                          << ", max iterations: " << currentMaxIter;
        log(logMsgBeforeWrite.str());  // Log to file

        // Write the image
        try {
            image.write(filename.str());

            std::stringstream logMsg;
            logMsg << "Generated image: " << filename.str()
                   << " with dimensions: " << width << "x" << height
                   << ", bit depth: " << bitDepth
                   << ", deposition size: " << currentDepositionSize
                   << ", max iterations: " << currentMaxIter;
            log(logMsg.str());  // Log to file
        } catch (Magick::Exception &error) {
            std::cerr << "Error writing image: " << error.what() << std::endl;
        }
    }

    return 0;
}
