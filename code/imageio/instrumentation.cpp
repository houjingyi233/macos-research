// Modified by @h02332 Davi dHoyt
// note that the .h is modified too

#include "instrumentation.h"
#include <iostream>
#include <sstream>
#include <cassert>
#include <ctime>
#include <csignal>

bool Instrumentation::debugMode = true;

std::string Instrumentation::AnonymizeAddress(void* addr) {
    char buf[20];
    snprintf(buf, sizeof(buf), "%p", addr);

    if (!strcmp(buf, "(nil)")) {
        std::cerr << "[" << __TIME__ << "] AnonymizeAddress: Address is nil" << std::endl;
        return std::string("0");
    }

    int addr_start = (buf[0] == '0' && (buf[1] == 'x' || buf[1] == 'X')) ? 2 : 0;
    int len = static_cast<int>(strlen(buf));
    int firstnonzero = len;
    for (int i = addr_start; i < len; i++) {
        if (buf[i] != '0') {
            firstnonzero = i;
            break;
        }
    }

    assert(firstnonzero < len); // Sanity check

    for (int i = firstnonzero; i < len - 3; i++) {
        buf[i] = 'x';
    }

    std::string anonymizedAddr(buf);
    std::cerr << "[" << __TIME__ << "] AnonymizeAddress: Original: " << addr
              << ", Anonymized: " << anonymizedAddr << std::endl;
    return anonymizedAddr;
}

void Instrumentation::DebugBreakpoint(const std::string& message) {
    if (debugMode) {
        std::cout << "[DEBUG BREAK] " << message << "\n";
        std::cout << "Press enter to continue...\n";
        std::cin.get();
    }
}

void Instrumentation::SignalHandler(int signal) {
    std::cout << "Caught signal " << signal << ". Entering debug mode.\n";
    debugMode = true;
}

void Instrumentation::SetupDebugMode() {
    std::signal(SIGINT, SignalHandler);
}
