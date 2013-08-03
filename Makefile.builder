ifeq ($(PACKAGE_SET),dom0)
RPM_SPEC_FILES := libvirt.spec
WIN_SOURCE_SUBDIRS := .
WIN_COMPILER := mingw
WIN_PACKAGE_CMD := true
endif
