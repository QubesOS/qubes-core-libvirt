ifneq ($(OS),Windows_NT)
default: help

NAME := libvirt
SPECFILE := libvirt.spec
include Makefile.common

.PHONY: verify-sources get-sources clean-sources clean

mrproper: clean
	-rm -fr rpm/* srpm/*

else

# Windows build start here

# This script uses three variables that contain Windows environment paths:
# MINGW_DIR should contain path to mingw environment (normally in chroot, prepared in Makefile.windows)
# PYTHON_DIR should contain python install path in chroot
# WIN_PATH is the search path used for configure/make, it should contain msys/mingw binaries and python directory

VERSION := $(shell cat version)
URL := http://libvirt.org/sources/$(mainturl)libvirt-$(VERSION).tar.gz

ifndef SRC_FILE
ifdef URL
	SRC_FILE := $(notdir $(URL))
endif
endif

get-sources: $(SRC_FILE)

$(SRC_FILE):
ifneq ($(SRC_FILE), None)
	@wget -q $(URL)
endif

.PHONY: verify-sources

verify-sources:
# This is a temporary hack, until libvirt project starts properly signing their tarballs...
ifneq ($(SRC_FILE), None)
	@md5sum -c sources-$(VERSION)
endif

all:
	tar xf $(SRC_FILE)
	cd libvirt-$(VERSION) && ../apply-patches ../series-qubes.conf ../patches.qubes
	cd libvirt-$(VERSION) && autoreconf
	# exported variables below should be initialized by the script that prepares windows build environment
	export PATH='$(WIN_PATH)'; export MINGW_DIR='$(MINGW_DIR)'; export PYTHON_DIR='$(PYTHON_DIR)'; cd libvirt-$(VERSION) && ../win-run-configure
	export PATH='$(WIN_PATH)'; cd libvirt-$(VERSION) && make -j$(NUMBER_OF_PROCESSORS)

endif
