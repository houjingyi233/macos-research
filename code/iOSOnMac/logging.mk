export VERBOSE ?= 0

# Control echoing based on VERBOSE
ifeq (0, $(VERBOSE))
.SILENT:
endif

# Redirect output if VERBOSE is 0
export _REDIRECT_OUTPUT = $(if $(findstring 0, $(VERBOSE)), > /dev/null)
export EXTRA_MAKE_FLAGS = $(if $(findstring 0, $(VERBOSE)), -s)

# Define color codes for logging
export BLUE := tput -Txterm setaf 6
export GREEN := tput -Txterm setaf 2
export WHITE := tput -Txterm setaf 7
export RED := tput -Txterm setaf 1
export RESET := tput -Txterm sgr0

# Set project display name
export PROJECT_DISPLAY_NAME := $(or ${PROJECT_NAME}, $(notdir $(shell pwd)))

# Define logging functions
log = @echo [$(PROJECT_DISPLAY_NAME)] - $(1)
log_build = ${BLUE} && $(call log, [++] Building $(notdir $(shell pwd))) && ${RESET}
log_clean = ${WHITE} && $(call log, [---] Cleaning $(notdir $(shell pwd))) && ${RESET}
log_die = ${RED} && @echo $1 && ${RESET} && @exit 1
check_path = which $1 >/dev/null || ($(RED) && echo "[$(PROJECT_DISPLAY_NAME)] - $2" && $(RESET) && exit 1)
