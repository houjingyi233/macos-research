# Set up all the variables we need to compile command line iOS applications
export PROJECT_PATH ?= $(dir $(realpath $(firstword ${MAKEFILE_LIST})))

export TOOLCHAIN ?= iOS17.0
export MACOS_TOOLCHAIN ?= MacOSX14.0
