ifeq ($(PACKAGE_SET),dom0)
RPM_SPEC_FILES := libvirt.spec
WIN_SOURCE_SUBDIRS := .
WIN_COMPILER := mingw
WIN_PACKAGE_CMD := true
endif

SOURCE_COPY_IN := copy-libvirt-backend
copy-libvirt-backend:
	@if [ -d "$(SRC_DIR)/core-libvirt-$(BACKEND_VMM)" ]; then \
	    rm -rf $(CHROOT_DIR)/$(DIST_SRC_ROOT)/core-libvirt-$(BACKEND_VMM) && \
	    cp -alt $(CHROOT_DIR)/$(DIST_SRC_ROOT) $(SRC_DIR)/core-libvirt-$(BACKEND_VMM) || exit 1; \
        sed -e "s/@DRIVER_NAME@/$(BACKEND_VMM)/g" \
            $(CHROOT_DIR)/$(DIST_SRC)/libvirt-external-driver.patch.in > \
            $(CHROOT_DIR)/$(DIST_SRC)/libvirt-external-driver.patch; \
	fi
