# myspack

Use cases and an example setup for user-space Spack chained to system
Spack.

System administrators work hard to make spack system software installs
robust, and hard to mess up --- for obvious reasons. This setup has a
different goal, to allow trying out spack and messing with it easy,
within user-space, but compatible enough with the system spack to be
useful. Read the disclaimer!

Possible uses of this kind of setup include

- convenient environment for developing spack packages
- installing user/project scope packages that can benefit from already
  installed system package dependencies


## Disclaimer

Please, do NOT run any of this stuff with admin priviledges, in
machines with write mounted system software root, with your other
admin account, etc, and you should be safe --- or rather, everybody
else should be safe :)

All files touched should be under this directory, only.

Out of the box, this should only work in puhti.csc.fi. Setup in other
machines will need adaptation.

You should be familiar with [the Spack
documentation](https://spack.readthedocs.io/en/latest/index.html#),
and chapter [Chaining Spack
Installations](https://spack.readthedocs.io/en/latest/chain.html),
especially.

## Setup

Read [myspack.sh](myspack.sh) carefully, and then source it:

```console
$ source myspack.sh
```

## Use cases/demos

1. [Using a different compiler to build an existing system Spack package](demos/demo-1.md)


## Open issues

### Issue 1, with hopefully temporal "fix"

There are some changes between the development branch, used in
myspack, and the stable spack version installed system wide. Some of
the packages are incompatible between the two. For example, running
`spack spec openmpi` for `openmpi` in `/appl/spack/csc-repo`, throws
error

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