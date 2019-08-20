# myspack

Use cases for user-space Spack chained to system Spack.

System administrators work hard to make spack system software installs
robust, and hard to mess up --- for a good reason. This setup has the
opposite goal, to allow trying out spack and messing with it
easy. Read the disclaimer :)


## Disclaimer

Please, do NOT run any of this stuff with admin priviledges, in the
machines with the write mounted system software root, with your other
admin account, etc, and you should be safe --- or rather, everybody
else should be safe :)

All files touched should be under this directory, only.

Out of the box, this should only work in puhti.csc.fi. Setup in other
machines likely needs adaptation.


## Setup

Read [myspack.sh](myspack.sh) carefully, and then source it:

```console
$ source myspack.sh
```

## Use cases/demos

1. [Using a different compiler to build an existing system Spack package](demos/demo-1.md)


## Open issues

### Issue 1, with slightly ugly, hopefully temporal "fix"

There are some changes between the development branch, used in
myspack, and the stable spack version installed system wide. Some of
the packages, such as `openmpi` in `/appl/spack/csc-repo`, are
incompatible, and running `spack spec ...` throws error

```console
Error: either a default was not explicitly set, or 'None' was used [mvapich2,
variant 'process_managers']`.
```

The setup [myspack.sh](myspack.sh) creates a "copy" of the
`/appl/spack/csc-repo` into `repos/csc` with the same `csc`
namespace. The copy of the repo has has soft links to the packages
which are needed and compatible to the original `csc-repo`,
only.


## Random notes

### Debugging spack, configuration, etc

```console
$ spack -d ...
```