# build.mk for iOS/macOS Application Development

# Project Path Configuration
export PROJECT_PATH ?= $(dir $(realpath $(firstword $(MAKEFILE_LIST))))

# Toolchain and SDK Settings
export TOOLCHAIN ?= iOS17.0
export MACOS_TOOLCHAIN ?= MacOSX14.0

# Architecture and SDK Configuration
export ARCH ?= arm64  # Adjust this to your target architecture
export SDK ?= iphoneos
