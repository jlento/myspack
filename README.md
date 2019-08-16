# myspack

Use cases for user-space Spack chained to system Spack


## Setup

Source [myspack.sh](myspack.sh):

```console
$ source myspack.sh
```


## Open issues

### Issue 1

There are some changes between myspack, which uses the development
branch, and the spack version installed system wide. Some of the
packages, such as `openmpi` in `/appl/spack/csc-repo` are
incompatible, and running `spack spec ...` throws error `Error: either
a default was not explicitly set, or 'None' was used [mvapich2,
variant 'process_managers']`.



## Use cases

### Case 1, building an existing system Spack package with a different compiler

Spack package `libemos@4.5.1` did build with system Spack with
`gcc@9.1.0`, but failed with `intel@19.0.4` compiler. Let's try to
build the intel version, too.

First, check if the package has already been updated in the Spack
development branch (myspack `$SPACK_ROOT` is in development branch by
default). Not so lucky here.

Next, and as always before trying to build a package, let's see what
dependencies need to be build:

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

The dependencies with minus sign in the front of the row would need to
be built. We could build them from the sources, but let's choose to
use as much as possible from the already installed system wide
packages. As a reference, let's see what packages were used to build
the `gcc@9.1.0` version:

```console
$ spack find -dl libemos@4.5.1 %gcc@9.1.0
==> 1 installed package
-- linux-rhel7-x86_64 / gcc@9.1.0 -------------------------------
gbu6b2s    libemos@4.5.1
2zjhzlj        ^eccodes@2.5.0
d5ze4lt            ^netcdf@4.7.0
zj7gvjh                ^hdf5@1.10.4
dnpueiz                    ^hpcx-mpi@2.4.0
mej2akp                    ^libszip@2.1.1
u2k4o6x                    ^numactl@2.0.11
nq5wt2f                    ^zlib@1.2.11
5qy2z2o            ^openjpeg@2.1.2
kbtnwnw        ^fftw@3.3.8
```

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

Now, let's do similarily for the other dependencies with the `-` sign,
picking the `%intel@19.0.4` when it matters.
