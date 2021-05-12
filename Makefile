ifneq ($(OS),Windows_NT)
default: help

NAME := libvirt
SPECFILE := libvirt.spec libvirt-python.spec
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

VERSION := $(or $(file <version),$(error Cannot determine version))
URL := https://libvirt.org/sources/$(mainturl)libvirt-$(VERSION).tar.xz

SRC_FILE := $(notdir $(URL))

get-sources: $(SRC_FILE)

UNTRUSTED_SUFF := .UNTRUSTED

ifeq ($(FETCH_CMD),)
$(error "You can not run this Makefile without having FETCH_CMD defined")
endif

$(SRC_FILE).asc:
	$(FETCH_CMD) $@ $(URL).asc

$(SRC_FILE): $(SRC_FILE).asc import-keys
	$(FETCH_CMD) $@$(UNTRUSTED_SUFF) $(URL)
	gpgv --keyring vmm-xen-trustedkeys.gpg $< $@$(UNTRUSTED_SUFF) 2>/dev/null || \
		{ echo "Wrong signature on $@$(UNTRUSTED_SUFF)!"; exit 1; }
	mv $@$(UNTRUSTED_SUFF) $@

.PHONY: import-keys
import-keys:
	@if [ -n "$$GNUPGHOME" ]; then rm -f "$$GNUPGHOME/core-libvirt-trustedkeys.gpg"; fi
	@gpg --no-auto-check-trustdb --no-default-keyring --keyring core-libvirt-trustedkeys.gpg -q --import *-key.asc

.PHONY: verify-sources

verify-sources:
	@true

# TODO: compile libvirt-python, apply patches.python
all:
	tar xf $(SRC_FILE)
	cd libvirt-$(VERSION) && ../apply-patches ../series-qubes.conf ../patches.qubes
	if test -r libvirt-external-driver.patch; then \
		patch -d libvirt-$(VERSION) -p1 < libvirt-external-driver.patch; fi
	cd libvirt-$(VERSION) && autoreconf
	# exported variables below should be initialized by the script that prepares windows build environment
	export PATH='$(WIN_PATH)'; export MINGW_DIR='$(MINGW_DIR)'; export PYTHON_DIR='$(PYTHON_DIR)'; cd libvirt-$(VERSION) && ../win-run-configure
	export PATH='$(WIN_PATH)'; cd libvirt-$(VERSION) && make -j$(NUMBER_OF_PROCESSORS)

msi:
	candle -arch x64 -dversion=$(VERSION) installer.wxs
	light -b libvirt-$(VERSION) -o core-libvirt.msm installer.wixobj

endif
