ifneq ($(DISTRIBUTION),windows)
default: help

NAME := libvirt
SPECFILE := libvirt.spec
include Makefile.common

.PHONY: verify-sources get-sources clean-sources clean

mrproper: clean
	-rm -fr rpm/* srpm/*

else

# Windows build start here

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
	@md5sum --quiet -c sources-$(VERSION)
endif

all:
	tar xf $(SRC_FILE)
	cd libvirt-$(VERSION) && ../apply-patches ../series-qubes.conf ../patches.qubes
	cd libvirt-$(VERSION) && autoreconf
	cd libvirt-$(VERSION) && ../win-run-configure
	cd libvirt-$(VERSION) && make -j$(NUMBER_OF_PROCESSORS)

endif
