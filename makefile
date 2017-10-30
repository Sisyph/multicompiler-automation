# makefile for multi-compiler project

#SHELL=/bin/bash

.PHONY: clean fetch

#llvm-cmake hypervisor-setup
PREFIX=$(realpath tools)

all:

#@echo "Prefix = $(value PREFIX)"

#download src
##############################
fetch: llvm llvm/tools/clang llvm/projects/compiler-rt llvm/projects/poolalloc llvm/projects/svf binutils

llvm:
	git clone -b cfar_38 git@github.com:/securesystemslab/multicompiler-priv.git llvm

llvm/tools/clang: llvm
	git clone -b cfar_38 git@github.com:/securesystemslab/multicompiler-clang-priv.git llvm/tools/clang

llvm/projects/compiler-rt: llvm
	git clone -b cfar_38 git@github.com:/securesystemslab/multicompiler-compiler-rt-priv.git llvm/projects/compiler-rt

llvm/projects/poolalloc: llvm
	git clone -b cfar_38 git@github.com:/securesystemslab/poolalloc llvm/projects/poolalloc

llvm/projects/svf: llvm
	git clone git@github.com:/rboggild/SVF llvm/projects/svf

binutils:
	git clone -b random_commons-2_26 git@github.com:/securesystemslab/binutils.git

##############################
install: gold.install clang.install outdir

gold.install: gold.build
	$(MAKE) -C binutils install

clang.install: tools/bin/clang tools/bin/ld.old tools/lib/bfd-plugins

outdir: clang.install
	mv tools/* /multicompiler

tools/bin/ld.old: gold.install
	mv tools/bin/ld tools/bin/ld.old; \
	ln -sf ld.gold tools/bin/ld

gold.build: gold.config
	$(MAKE) -j -C binutils

gold.config: binutils/.binutils_configured

binutils/.binutils_configured:
	./configure_binutils.sh $(PREFIX)

llvm/build:
	./setup_llvm.sh $(PREFIX)

tools/lib/bfd-plugins: tools/bin/clang gold.install
	./create_bfd_plugins.sh

tools/bin/clang: llvm/build
	./build_clang.sh

#clang: tools/lib/bfd-plugins

clean: clean_install
	rm -rf llvm
	rm -rf binutils

clean_llvm:
	rm -rf llvm/build

clean_install:
	rm -rf tools/*

