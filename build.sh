#!/bin/bash -e

DISTRO=$(grep ^ID= /etc/os-release | cut -d'=' -f 2)

if [[ $DISTRO = 'ubuntu' ]]; then
    ./install_ubuntu_packages.sh
fi

if [ ! -d "llvm" ]; then
    make fetch 
else
    ./git_pull.sh
fi

./patch_printf.bash

echo Building Multicompiler ...
make install
