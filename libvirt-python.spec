

%if 0%{?qubes_builder}
%define _sourcedir %(pwd)
%endif
%{!?version: %define version %(cat version)}

%define with_python3 0
%if 0%{?fedora} > 18
%define with_python3 1
%endif

Summary: The libvirt virtualization API python2 binding
Name: libvirt-python
Version: %{version}
Release: 1%{?dist}%{?extra_release}
Source: http://libvirt.org/sources/python/%{name}-%{version}.tar.gz
Url: http://libvirt.org
Patch0: 0001-libvirtaio-add-more-debug-logging.patch
Patch1: 0002-libvirtaio-cache-the-list-of-callbacks-when-calling.patch
Patch2: 0003-libvirtaio-do-not-double-add-callbacks.patch
Patch3: 0004-libvirtaio-fix-closing-of-the-objects.patch
Patch4: 0005-libvirtaio-keep-track-of-the-current-implementation.patch
Patch5: 0006-libvirtaio-add-.drain-coroutine.patch
License: LGPLv2+
Group: Development/Libraries
BuildRequires: libvirt-devel >= 0.9.11
BuildRequires: python-devel
BuildRequires: python-nose
BuildRequires: python-lxml
#%%if %{with_python3}
BuildRequires: python3-devel
BuildRequires: python3-nose
BuildRequires: python3-lxml
#%%endif

#%%if %{with_python3}
%package -n libvirt-python3
Summary: The libvirt virtualization API python3 binding
Url: http://libvirt.org
License: LGPLv2+
Group: Development/Libraries
#%%endif

# Don't want provides for python shared objects
%{?filter_provides_in: %filter_provides_in %{python_sitearch}/.*\.so}
%{?filter_setup}

%description
The libvirt-python package contains a module that permits applications
written in the Python programming language to use the interface
supplied by the libvirt library to use the virtualization capabilities
of recent versions of Linux (and other OSes).

#%%if %{with_python3}
%description -n libvirt-python3
The libvirt-python package contains a module that permits applications
written in the Python programming language to use the interface
supplied by the libvirt library to use the virtualization capabilities
of recent versions of Linux (and other OSes).
#%%endif

%prep
%setup -q

# Patches have to be stored in a temporary file because RPM has
# a limit on the length of the result of any macro expansion;
# if the string is longer, it's silently cropped
%{lua:
    tmp = os.tmpname();
    f = io.open(tmp, "w+");
    count = 0;
    for i, p in ipairs(patches) do
        f:write(p.."\n");
        count = count + 1;
    end;
    f:close();
    print("PATCHCOUNT="..count.."\n")
    print("PATCHLIST="..tmp.."\n")
}

%if 0%{?qubes_builder}
ln -s %{_sourcedir}/patches.python/*.patch %{_sourcedir}/
%endif

git init -q
git config user.name rpm-build
git config user.email rpm-build
git config gc.auto 0
git add .
git commit -q -a --author 'rpm-build <rpm-build>' \
           -m '%{name}-%{version} base'

COUNT=$(grep '\.patch$' $PATCHLIST | wc -l)
if [ $COUNT -ne $PATCHCOUNT ]; then
    echo "Found $COUNT patches in $PATCHLIST, expected $PATCHCOUNT"
    exit 1
fi
if [ $COUNT -gt 0 ]; then
    xargs git am <$PATCHLIST || exit 1
fi
echo "Applied $COUNT patches"
rm -f $PATCHLIST
rm -rf .git

%build
CFLAGS="$RPM_OPT_FLAGS" %{__python} setup.py build
#%%if %{with_python3}
CFLAGS="$RPM_OPT_FLAGS" %{__python3} setup.py build
#%%endif

%install
%{__python} setup.py install --skip-build --root=%{buildroot}
#%%if %{with_python3}
%{__python3} setup.py install --skip-build --root=%{buildroot}
#%%endif
rm -f %{buildroot}%{_libdir}/python*/site-packages/*egg-info

%check
%{__python} setup.py test
#%%if %{with_python3}
%{__python3} setup.py test
#%%endif

%files
%defattr(-,root,root)
%doc ChangeLog AUTHORS NEWS README COPYING COPYING.LESSER examples/
%{_libdir}/python2*/site-packages/libvirt.py*
%{_libdir}/python2*/site-packages/libvirt_qemu.py*
%{_libdir}/python2*/site-packages/libvirt_lxc.py*
%{_libdir}/python2*/site-packages/libvirtmod*

#%%if %{with_python3}
%files -n libvirt-python3
%defattr(-,root,root)
%doc ChangeLog AUTHORS NEWS README COPYING COPYING.LESSER examples/
%{_libdir}/python3*/site-packages/libvirt.py*
%{_libdir}/python3*/site-packages/libvirtaio.py*
%{_libdir}/python3*/site-packages/libvirt_qemu.py*
%{_libdir}/python3*/site-packages/libvirt_lxc.py*
%{_libdir}/python3*/site-packages/__pycache__/libvirt.cpython-*.py*
%{_libdir}/python3*/site-packages/__pycache__/libvirtaio.cpython-*.py*
%{_libdir}/python3*/site-packages/__pycache__/libvirt_qemu.cpython-*.py*
%{_libdir}/python3*/site-packages/__pycache__/libvirt_lxc.cpython-*.py*
%{_libdir}/python3*/site-packages/libvirtmod*
#%%endif

%changelog
