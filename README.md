# Qubes libvirt

This repository packages [libvirt](https://libvirt.org/) for
[Qubes OS](https://www.qubes-os.org). It takes the upstream libvirt release and
applies a set of Qubes patches, mostly to the libxl (Xen) driver, so that Qubes
can manage its VMs through libvirt on top of Xen.

The build pulls the upstream `libvirt` and `libvirt-python` sources, applies the
patches in this repository, and produces the packages used in dom0.

For how Qubes components are built, see the
[Qubes builder documentation](https://www.qubes-os.org/doc/qubes-builder/).
