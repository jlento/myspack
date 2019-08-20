# Building an existing system Spack package with a different
compiler

Spack package `libemos@4.5.1` did build with the system Spack with
`gcc@9.1.0`, but failed with `intel@19.0.4` compiler. Let's try to
build the intel version, too.

First, check if the package has already been updated in the Spack
development branch (myspack `$SPACK_ROOT` is in development branch by
default). Not so lucky here. Looks like we are the ones that need to
do the update.


## Make a reference to the existing package

As a reference, let's see what packages were used to build
the `gcc@9.1.0` version,

```console
$ spack find -dlN libemos@4.5.1 %gcc@9.1.0
==> 1 installed package
-- linux-rhel7-x86_64 / gcc@9.1.0 -------------------------------
gbu6b2s    builtin.libemos@4.5.1
2zjhzlj        ^builtin.eccodes@2.5.0
d5ze4lt            ^csc.netcdf@4.7.0
zj7gvjh                ^builtin.hdf5@1.10.4
dnpueiz                    ^csc.hpcx-mpi@2.4.0
mej2akp                    ^builtin.libszip@2.1.1
u2k4o6x                    ^builtin.numactl@2.0.11
nq5wt2f                    ^builtin.zlib@1.2.11
5qy2z2o            ^builtin.openjpeg@2.1.2
kbtnwnw        ^builtin.fftw@3.3.8
```

and which variants etc. were specified,

```console
$ spack spec /gbu6b2s
Input spec
--------------------------------
libemos@4.5.1%gcc@9.1.0 build_type=RelWithDebInfo grib=eccodes arch=linux-rhel7-x86_64
    ^eccodes@2.5.0%gcc@9.1.0~aec build_type=RelWithDebInfo +examples+fortran jp2k=openjpeg ~memfs+netcdf~openmp patches=933f4104caac79bc41cbaf6372d72e6f8b3beae21e507055ccda9066632a137c,caa4c2f2ac4a13a61c3372cd64f2f6f6570c78ed2ab91497a76b02c584abe1bc ~png~pthreads~python+test arch=linux-rhel7-x86_64
        ^netcdf@4.7.0%gcc@9.1.0~dap~hdf4 maxdims=1024 maxvars=8192 +mpi~parallel-netcdf patches=10a1c3f7fa05e2c82457482e272bbe04d66d0047b237ad0a73e87d63d848b16c +pic+shared arch=linux-rhel7-x86_64
            ^hdf5@1.10.4%gcc@9.1.0~cxx~debug+fortran+hl+mpi+pic+shared+szip+threadsafe arch=linux-rhel7-x86_64
                ^hpcx-mpi@2.4.0%gcc@9.1.0~cuda arch=linux-rhel7-x86_64
                ^libszip@2.1.1%gcc@9.1.0 arch=linux-rhel7-x86_64
                ^numactl@2.0.11%gcc@9.1.0 patches=592f30f7f5f757dfc239ad0ffd39a9a048487ad803c26b419e0f96b8cda08c1a arch=linux-rhel7-x86_64
                ^zlib@1.2.11%gcc@9.1.0+optimize+pic+shared arch=linux-rhel7-x86_64
        ^openjpeg@2.1.2%gcc@9.1.0 build_type=RelWithDebInfo arch=linux-rhel7-x86_64
    ^fftw@3.3.8%gcc@9.1.0+double+float+fma+long_double+mpi~openmp~pfft_patches~quad simd=avx512 arch=linux-rhel7-x86_64
...
```


## Iterating on the spec

Let's see what the simplest case would look like:

```console
$ spack spec -I libemos@4.5.1 %intel@19.0.4
Input spec
--------------------------------
 -   libemos@4.5.1%intel@19.0.4

Concretized
--------------------------------
 -   libemos@4.5.1%intel@19.0.4 build_type=RelWithDebInfo grib=eccodes arch=linux-rhel7-x86_64
 -       ^cmake@3.15.1%intel@19.0.4~doc+ncurses+openssl+ownlibs~qt arch=linux-rhel7-x86_64
[^]          ^ncurses@6.1%intel@19.0.4~symlinks~termlib arch=linux-rhel7-x86_64
 -               ^pkgconf@1.6.1%intel@19.0.4 arch=linux-rhel7-x86_64
[^]          ^openssl@1.0.2k%intel@19.0.4+systemcerts arch=linux-rhel7-x86_64
 -       ^eccodes@2.13.0%intel@19.0.4~aec build_type=RelWithDebInfo +examples~fortran jp2k=openjpeg ~memfs~netcdf~openmp patches=933f4104caac79bc41cbaf6372d72e6f8b3beae21e507055ccda9066632a137c,caa4c2f2ac4a13a61c3372cd64f2f6f6570c78ed2ab91497a76b02c584abe1bc ~png~pthreads~python+test arch=linux-rhel7-x86_64
[^]          ^openjpeg@2.1.2%intel@19.0.4 build_type=RelWithDebInfo arch=linux-rhel7-x86_64
 -       ^fftw@3.3.8%intel@19.0.4+double+float+fma+long_double+mpi~openmp~pfft_patches~quad simd=avx512 arch=linux-rhel7-x86_64
[^]          ^intel-mpi@18.0.5%intel@19.0.4 arch=linux-rhel7-x86_64
```

### Variants

Comparing to the `gcc@9.1.0` reference, the variant spec seem to the same without modifications.

### Dependencies

The dependencies with minus sign in the front of the row in the
concretized spec would need to be built. We could build them from the
sources, but let's choose to use as much as possible from the already
installed system wide packages.

Note, this process is recursive...

#### Dependency iteration 1

The first package that would need to be built with the `libemos@4.5.1
%intel@19.0.4` spec is `cmake@3.15.1`. Let 's see if we already have
something that could be used instead of it:

```console
$ spack find -l cmake
==> 9 installed packages
-- linux-rhel7-x86_64 / gcc@4.8.5 -------------------------------
whwokdf cmake@2.8.10.2  2cfd634 cmake@3.9.6  bmoi4rw cmake@3.12.3

-- linux-rhel7-x86_64 / gcc@8.3.0 -------------------------------
nv3bwln cmake@3.9.4

-- linux-rhel7-x86_64 / gcc@9.1.0 -------------------------------
mqkt3mv cmake@3.12.3

-- linux-rhel7-x86_64 / intel@18.0.5 ----------------------------
57fyjh6 cmake@3.9.6  hdb5lmh cmake@3.12.3

-- linux-rhel7-x86_64 / intel@19.0.4 ----------------------------
pvd63sq cmake@3.9.6  akxrk7w cmake@3.12.3
```

The `cmake@3.12.3%gcc@4.8.5` is the same as used for the `gcc@9.1.0`,
and cmake does not need to be build with a particular compiler, so
let's use it by adding it's checksum `bmoi4rw` as a dependency:

```console
$ spack spec -I libemos %intel@19.0.4 ^cmake/bmoi4rw
Input spec
--------------------------------
 -   libemos%intel@19.0.4
[^]      ^cmake@3.12.3%gcc@4.8.5~doc+ncurses+openssl+ownlibs patches=dd3a40d4d92f6b2158b87d6fb354c277947c776424aa03f6dc8096cf3135f5d0 ~qt arch=linux-rhel7-x86_64
[^]          ^ncurses@6.1%gcc@4.8.5~symlinks~termlib arch=linux-rhel7-x86_64
[^]          ^openssl@1.0.2k%gcc@4.8.5+systemcerts arch=linux-rhel7-x86_64

Concretized
--------------------------------
 -   libemos@4.5.1%intel@19.0.4 build_type=RelWithDebInfo grib=eccodes arch=linux-rhel7-x86_64
[^]      ^cmake@3.12.3%gcc@4.8.5~doc+ncurses+openssl+ownlibs patches=dd3a40d4d92f6b2158b87d6fb354c277947c776424aa03f6dc8096cf3135f5d0 ~qt arch=linux-rhel7-x86_64
[^]          ^ncurses@6.1%gcc@4.8.5~symlinks~termlib arch=linux-rhel7-x86_64
[^]          ^openssl@1.0.2k%gcc@4.8.5+systemcerts arch=linux-rhel7-x86_64
 -       ^eccodes@2.13.0%intel@19.0.4~aec build_type=RelWithDebInfo +examples~fortran jp2k=openjpeg ~memfs~netcdf~openmp patches=933f4104caac79bc41cbaf6372d72e6f8b3beae21e507055ccda9066632a137c,caa4c2f2ac4a13a61c3372cd64f2f6f6570c78ed2ab91497a76b02c584abe1bc ~png~pthreads~python+test arch=linux-rhel7-x86_64
[^]          ^openjpeg@2.1.2%intel@19.0.4 build_type=RelWithDebInfo arch=linux-rhel7-x86_64
 -       ^fftw@3.3.8%intel@19.0.4+double+float+fma+long_double+mpi~openmp~pfft_patches~quad simd=avx512 arch=linux-rhel7-x86_64
[^]          ^intel-mpi@18.0.5%intel@19.0.4 arch=linux-rhel7-x86_64
 -       ^pkgconf@1.6.1%intel@19.0.4 arch=linux-rhel7-x86_64
```

Great!

#### Dependency iteration 2

Next missing dependency is `eccodes@2.13.0%intel@19.0.4`. Let's see if
we can find something for that already in the system packages:

```console
$ spack find -ldN eccodes
==> 4 installed packages
-- linux-rhel7-x86_64 / gcc@9.1.0 -------------------------------
irp35l6    builtin.eccodes@2.5.0
5qy2z2o        ^builtin.openjpeg@2.1.2

2zjhzlj    builtin.eccodes@2.5.0
d5ze4lt        ^csc.netcdf@4.7.0
zj7gvjh            ^builtin.hdf5@1.10.4
dnpueiz                ^csc.hpcx-mpi@2.4.0
mej2akp                ^builtin.libszip@2.1.1
u2k4o6x                ^builtin.numactl@2.0.11
nq5wt2f                ^builtin.zlib@1.2.11
5qy2z2o        ^builtin.openjpeg@2.1.2


-- linux-rhel7-x86_64 / intel@19.0.4 ----------------------------
pmikpah    builtin.eccodes@2.5.0
pg2pjoh        ^builtin.openjpeg@2.1.2

dpk7ts4    builtin.eccodes@2.5.0
5xwiijo        ^csc.netcdf@4.7.0
z72kbdc            ^builtin.hdf5@1.10.4
keuon4j                ^csc.hpcx-mpi@2.4.0
nxcvwvs                ^builtin.libszip@2.1.1
xlbts6m                ^builtin.numactl@2.0.11
e76n5d3                ^builtin.zlib@1.2.11
pg2pjoh        ^builtin.openjpeg@2.1.2
```

There are two system packages candidates that look promising, both
named `eccodes@2.5.0 %intel@19.0.4`. The system package version is
older than the one picked up from the spack development branch by
default, but it matches our `gcc@9.1.0` reference system
package. Let's go with `eccodes@2.5.0`.

To choose between the two candidates, let's see which one matches
better the one used by out reference package,

```console
$ spack find -ldN /2zjhzlj
==> 1 installed package
-- linux-rhel7-x86_64 / gcc@9.1.0 -------------------------------
2zjhzlj    builtin.eccodes@2.5.0
d5ze4lt        ^csc.netcdf@4.7.0
zj7gvjh            ^builtin.hdf5@1.10.4
dnpueiz                ^csc.hpcx-mpi@2.4.0
mej2akp                ^builtin.libszip@2.1.1
u2k4o6x                ^builtin.numactl@2.0.11
nq5wt2f                ^builtin.zlib@1.2.11
5qy2z2o        ^builtin.openjpeg@2.1.2
```

Looks like `eccodes/dpk7ts4`. Let's see what our spec looks like with it:

```console
 spack spec -I libemos %intel@19.0.4 ^cmake/bmoi4rw ^eccodes/dpk7ts4
Input spec
--------------------------------
 -   libemos%intel@19.0.4
[^]      ^cmake@3.12.3%gcc@4.8.5~doc+ncurses+openssl+ownlibs patches=dd3a40d4d92f6b2158b87d6fb354c277947c776424aa03f6dc8096cf3135f5d0 ~qt arch=linux-rhel7-x86_64
[^]          ^ncurses@6.1%gcc@4.8.5~symlinks~termlib arch=linux-rhel7-x86_64
[^]          ^openssl@1.0.2k%gcc@4.8.5+systemcerts arch=linux-rhel7-x86_64
[^]      ^eccodes@2.5.0%intel@19.0.4~aec build_type=RelWithDebInfo +examples+fortran jp2k=openjpeg ~memfs+netcdf~openmp patches=933f4104caac79bc41cbaf6372d72e6f8b3beae21e507055ccda9066632a137c,caa4c2f2ac4a13a61c3372cd64f2f6f6570c78ed2ab91497a76b02c584abe1bc ~png~pthreads~python+test arch=linux-rhel7-x86_64
[^]          ^netcdf@4.7.0%intel@19.0.4~dap~hdf4 maxdims=1024 maxvars=8192 +mpi~parallel-netcdf patches=10a1c3f7fa05e2c82457482e272bbe04d66d0047b237ad0a73e87d63d848b16c +pic+shared arch=linux-rhel7-x86_64
[^]              ^hdf5@1.10.4%intel@19.0.4~cxx~debug+fortran+hl+mpi+pic+shared+szip+threadsafe arch=linux-rhel7-x86_64
[^]                  ^hpcx-mpi@2.4.0%intel@19.0.4~cuda arch=linux-rhel7-x86_64
[^]                  ^libszip@2.1.1%intel@19.0.4 arch=linux-rhel7-x86_64
[^]                  ^numactl@2.0.11%intel@19.0.4 patches=592f30f7f5f757dfc239ad0ffd39a9a048487ad803c26b419e0f96b8cda08c1a arch=linux-rhel7-x86_64
[^]                  ^zlib@1.2.11%intel@19.0.4+optimize+pic+shared arch=linux-rhel7-x86_64
[^]          ^openjpeg@2.1.2%intel@19.0.4 build_type=RelWithDebInfo arch=linux-rhel7-x86_64

Concretized
--------------------------------
 -   libemos@4.5.1%intel@19.0.4 build_type=RelWithDebInfo grib=eccodes arch=linux-rhel7-x86_64
[^]      ^cmake@3.12.3%gcc@4.8.5~doc+ncurses+openssl+ownlibs patches=dd3a40d4d92f6b2158b87d6fb354c277947c776424aa03f6dc8096cf3135f5d0 ~qt arch=linux-rhel7-x86_64
[^]          ^ncurses@6.1%gcc@4.8.5~symlinks~termlib arch=linux-rhel7-x86_64
[^]          ^openssl@1.0.2k%gcc@4.8.5+systemcerts arch=linux-rhel7-x86_64
[^]      ^eccodes@2.5.0%intel@19.0.4~aec build_type=RelWithDebInfo +examples+fortran jp2k=openjpeg ~memfs+netcdf~openmp patches=933f4104caac79bc41cbaf6372d72e6f8b3beae21e507055ccda9066632a137c,caa4c2f2ac4a13a61c3372cd64f2f6f6570c78ed2ab91497a76b02c584abe1bc ~png~pthreads~python+test arch=linux-rhel7-x86_64
[^]          ^netcdf@4.7.0%intel@19.0.4~dap~hdf4 maxdims=1024 maxvars=8192 +mpi~parallel-netcdf patches=10a1c3f7fa05e2c82457482e272bbe04d66d0047b237ad0a73e87d63d848b16c +pic+shared arch=linux-rhel7-x86_64
[^]              ^hdf5@1.10.4%intel@19.0.4~cxx~debug+fortran+hl+mpi+pic+shared+szip+threadsafe arch=linux-rhel7-x86_64
[^]                  ^hpcx-mpi@2.4.0%intel@19.0.4~cuda arch=linux-rhel7-x86_64
[^]                  ^libszip@2.1.1%intel@19.0.4 arch=linux-rhel7-x86_64
[^]                  ^numactl@2.0.11%intel@19.0.4 patches=592f30f7f5f757dfc239ad0ffd39a9a048487ad803c26b419e0f96b8cda08c1a arch=linux-rhel7-x86_64
[^]                  ^zlib@1.2.11%intel@19.0.4+optimize+pic+shared arch=linux-rhel7-x86_64
[^]          ^openjpeg@2.1.2%intel@19.0.4 build_type=RelWithDebInfo arch=linux-rhel7-x86_64
[^]      ^fftw@3.3.8%intel@19.0.4+double+float+fma+long_double+mpi~openmp~pfft_patches~quad simd=avx512 arch=linux-rhel7-x86_64
 -       ^pkgconf@1.6.1%intel@19.0.4 arch=linux-rhel7-x86_64
```

Looks great, only `pkgconfig` dependency needs rebuilding, but it does
not depend on the compiler, and we can find a system package the same
way as for `cmake`.

```console
$ spack spec -I libemos %intel@19.0.4 ^cmake/bmoi4rw ^eccodes/dpk7ts4 ^pkgconfig/7yuszxv
Input spec
--------------------------------
 -   libemos%intel@19.0.4
[^]      ^cmake@3.12.3%gcc@4.8.5~doc+ncurses+openssl+ownlibs patches=dd3a40d4d92f6b2158b87d6fb354c277947c776424aa03f6dc8096cf3135f5d0 ~qt arch=linux-rhel7-x86_64
[^]          ^ncurses@6.1%gcc@4.8.5~symlinks~termlib arch=linux-rhel7-x86_64
[^]          ^openssl@1.0.2k%gcc@4.8.5+systemcerts arch=linux-rhel7-x86_64
[^]      ^eccodes@2.5.0%intel@19.0.4~aec build_type=RelWithDebInfo +examples+fortran jp2k=openjpeg ~memfs+netcdf~openmp patches=933f4104caac79bc41cbaf6372d72e6f8b3beae21e507055ccda9066632a137c,caa4c2f2ac4a13a61c3372cd64f2f6f6570c78ed2ab91497a76b02c584abe1bc ~png~pthreads~python+test arch=linux-rhel7-x86_64
[^]          ^netcdf@4.7.0%intel@19.0.4~dap~hdf4 maxdims=1024 maxvars=8192 +mpi~parallel-netcdf patches=10a1c3f7fa05e2c82457482e272bbe04d66d0047b237ad0a73e87d63d848b16c +pic+shared arch=linux-rhel7-x86_64
[^]              ^hdf5@1.10.4%intel@19.0.4~cxx~debug+fortran+hl+mpi+pic+shared+szip+threadsafe arch=linux-rhel7-x86_64
[^]                  ^hpcx-mpi@2.4.0%intel@19.0.4~cuda arch=linux-rhel7-x86_64
[^]                  ^libszip@2.1.1%intel@19.0.4 arch=linux-rhel7-x86_64
[^]                  ^numactl@2.0.11%intel@19.0.4 patches=592f30f7f5f757dfc239ad0ffd39a9a048487ad803c26b419e0f96b8cda08c1a arch=linux-rhel7-x86_64
[^]                  ^zlib@1.2.11%intel@19.0.4+optimize+pic+shared arch=linux-rhel7-x86_64
[^]          ^openjpeg@2.1.2%intel@19.0.4 build_type=RelWithDebInfo arch=linux-rhel7-x86_64
[^]      ^pkgconf@1.4.2%gcc@4.8.5 arch=linux-rhel7-x86_64

Concretized
--------------------------------
 -   libemos@4.5.1%intel@19.0.4 build_type=RelWithDebInfo grib=eccodes arch=linux-rhel7-x86_64
[^]      ^cmake@3.12.3%gcc@4.8.5~doc+ncurses+openssl+ownlibs patches=dd3a40d4d92f6b2158b87d6fb354c277947c776424aa03f6dc8096cf3135f5d0 ~qt arch=linux-rhel7-x86_64
[^]          ^ncurses@6.1%gcc@4.8.5~symlinks~termlib arch=linux-rhel7-x86_64
[^]          ^openssl@1.0.2k%gcc@4.8.5+systemcerts arch=linux-rhel7-x86_64
[^]      ^eccodes@2.5.0%intel@19.0.4~aec build_type=RelWithDebInfo +examples+fortran jp2k=openjpeg ~memfs+netcdf~openmp patches=933f4104caac79bc41cbaf6372d72e6f8b3beae21e507055ccda9066632a137c,caa4c2f2ac4a13a61c3372cd64f2f6f6570c78ed2ab91497a76b02c584abe1bc ~png~pthreads~python+test arch=linux-rhel7-x86_64
[^]          ^netcdf@4.7.0%intel@19.0.4~dap~hdf4 maxdims=1024 maxvars=8192 +mpi~parallel-netcdf patches=10a1c3f7fa05e2c82457482e272bbe04d66d0047b237ad0a73e87d63d848b16c +pic+shared arch=linux-rhel7-x86_64
[^]              ^hdf5@1.10.4%intel@19.0.4~cxx~debug+fortran+hl+mpi+pic+shared+szip+threadsafe arch=linux-rhel7-x86_64
[^]                  ^hpcx-mpi@2.4.0%intel@19.0.4~cuda arch=linux-rhel7-x86_64
[^]                  ^libszip@2.1.1%intel@19.0.4 arch=linux-rhel7-x86_64
[^]                  ^numactl@2.0.11%intel@19.0.4 patches=592f30f7f5f757dfc239ad0ffd39a9a048487ad803c26b419e0f96b8cda08c1a arch=linux-rhel7-x86_64
[^]                  ^zlib@1.2.11%intel@19.0.4+optimize+pic+shared arch=linux-rhel7-x86_64
[^]          ^openjpeg@2.1.2%intel@19.0.4 build_type=RelWithDebInfo arch=linux-rhel7-x86_64
[^]      ^fftw@3.3.8%intel@19.0.4+double+float+fma+long_double+mpi~openmp~pfft_patches~quad simd=avx512 arch=linux-rhel7-x86_64
[^]      ^pkgconf@1.4.2%gcc@4.8.5 arch=linux-rhel7-x86_64
```

Now the spec looks fine, and we did find likely suitable versions of
all the dependencies from the already installed system packages.


## Fixing the package, building and installing it

We already know that this should initally fail, but let's run the
install command:

```console
$ spack install -Iv libemos %intel@19.0.4 ^cmake/bmoi4rw ^eccodes/dpk7ts4 ^pkgconfig/7yuszxv
```

The output is a bit longish, but the relevant part is that the Intel
compiler is given a compile option `-ffree-line-lenght-none`,
that should be given to GCC compiler, only. That should be easy to fix!

We can override the package.py build recipe from the builtin package
repository `spack/var/spack/repos/builtin/` by creating the same named
package in the repository `repos/myspack/`, which is
listed before in the repository list `spack/etc/spack/repos.yaml`.

Let's just copy the package (dirctory) and make the required
modification to `package.py`. The final diff

```console
$ diff spack/var/spack/repos/builtin/packages/libemos/package.py repos/myspack/packages/libemos/package.py
48c48,49
<         args.append('-DCMAKE_Fortran_FLAGS=-ffree-line-length-none')
---
>         if self.spec.satisfies('%gcc'):
>             args.append('-DCMAKE_Fortran_FLAGS=-ffree-line-length-none')
```

shows the simple guard that checks which compiler is in use.

Now the package builds with Intel compiler too, and our task is accomplished!
