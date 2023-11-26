# Set VERBOSE=1 on the command line for more verbosity!
export VERBOSE ?= 1

# Include additional Makefiles
include logging.mk
include build.mk

# Define tools and flags
CC = clang
XCRUN = xcrun -sdk iphoneos
CFLAGS = -arch arm64 -g
CODESIGN = codesign
DEVELOPER_ID = "Developer ID"
ENTITLEMENTS = entitlements.xml

# Targets
RUNNER_TARGET = runner
RUNNER_SRC = runner.c
INTERPOSE_TARGET = interpose.dylib
INTERPOSE_SRC = interpose.c
MAIN_TARGET = main.app/main
MAIN_SRC = main.c
APP_DIR = main.app

# Default target
all: $(RUNNER_TARGET) $(MAIN_TARGET)

# Build runner
$(RUNNER_TARGET): $(RUNNER_SRC)
	@$(call log, Building runner with macOS SDK)
	$(CC) -o $(RUNNER_TARGET) $(RUNNER_SRC)
	$(CODESIGN) -s $(DEVELOPER_ID) --entitlements $(ENTITLEMENTS) --force $(RUNNER_TARGET)

# Build main and create app bundle
$(MAIN_TARGET): $(MAIN_SRC) $(INTERPOSE_TARGET)
	@$(call log, Building main.app with iOS SDK)
	$(XCRUN) $(CC) $(CFLAGS) -o main $(MAIN_SRC) $(INTERPOSE_TARGET)
	@$(call log, Creating main.app...)
	mkdir -p $(APP_DIR)
	cp Info.plist $(APP_DIR)/
	mv main $(APP_DIR)/
	@$(call log, Created main.app... Codesigning....)
	$(CODESIGN) -s $(DEVELOPER_ID) --entitlements $(ENTITLEMENTS) --force $(APP_DIR)

# Build interpose.dylib
$(INTERPOSE_TARGET): $(INTERPOSE_SRC)
	@$(call log, Building interpose.dylib with iOS SDK)
	$(XCRUN) $(CC) $(CFLAGS) -o $(INTERPOSE_TARGET) -shared $(INTERPOSE_SRC)

# Clean up build artifacts
clean:
	@$(call log, Cleaning up......)
	rm -rf $(RUNNER_TARGET) $(INTERPOSE_TARGET) $(APP_DIR)

.PHONY: all clean

