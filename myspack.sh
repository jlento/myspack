#!/bin/bash
source <(sed '1,/^__FUNCS__/d' ${BASH_SOURCE[0]})

# Set up user-space spack enviromenment that is chained to system spack

export SPACK_ROOT=$(cd $(dirname ${BASH_SOURCE[0]});pwd)/spack
export SPACK_UPSTREAM_ROOT=/appl/spack/spack
export SPACK_UPSTREAM_INSTALL_TREE=/appl/spack/install-tree

myspack-create-git-repository \
    $SPACK_ROOT https://github.com/spack/spack.git || return
myspack-configure \
    $SPACK_ROOT $SPACK_UPSTREAM_ROOT $SPACK_UPSTREAM_INSTALL_TREE || return

source $SPACK_ROOT/share/spack/{setup-env,spack-completion}.sh

return


__FUNCS__

myspack-create-git-repository () {
    local usage="
        Usage: ${FUNCNAME[0]} MYSPACK_ROOT MYSPACK_REPOSITORY
        "
    local spackroot=${1:?$usage}
    local spackurl=${2:?$usage}
    mkdir -p $(dirname $spackroot)
    echo "${spackroot}:"
    ( cd $spackroot && \
	git remote update && \
	git status -uno || \
	git clone $spackurl $spackroot
    ) | sed 's/^/    /'
}

myspack-configure () {
    local usage="
        Usage ${FUNCNAME[0]} SPACK_ROOT UPSTREAM_ROOT [UPSTREAM_INSTALL_TREE]
        "
    local spackroot=${1:?$usage}
    local upstreamroot=${2:?$usage}
    local upstreamtree=${3:-$2/opt/spack}
    echo > $spackroot/etc/spack/upstreams.yaml "
        upstreams:
            spack-instance-1:
                install_tree: $upstreamtree
        "
    echo > $(dirname $spackroot)/repos/myspack/repo.yaml "
        repo:
            namespace: myspack
        "
    echo > $spackroot/etc/spack/repos.yaml "
        repos:
            - $(dirname $spackroot)/repos/myspack
            - $(dirname $spackroot)/repos/csc
            - \$spack/var/spack/repos/builtin
        "
    mkdir -p $(dirname $spackroot)/repos/csc/packages
    ln -sf $(dirname $upstreamroot)/csc-repo/repo.yaml \
	$(dirname $spackroot)/repos/csc/
    ln -sf $(dirname $upstreamroot)/csc-repo/packages/{hpcx-mpi,netcdf} \
	$(dirname $spackroot)/repos/csc/packages/
    sed -e '/^    permissions:/,+2d' $upstreamroot/etc/spack/packages.yaml \
	> $spackroot/etc/spack/packages.yaml
    ln -sf \
	$upstreamroot/etc/spack/{compilers}.yaml \
	$spackroot/etc/spack
}
