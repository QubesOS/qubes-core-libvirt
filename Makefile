default: help

NAME := libvirt
SPECFILE := libvirt.spec
include Makefile.common

.PHONY: verify-sources get-sources clean-sources clean

mrproper: clean
	-rm -fr rpm/* srpm/*
