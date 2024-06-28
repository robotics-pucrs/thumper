#!/bin/sh

# this script was written by Sergio Johann Filho [sergio.johann@acad.pucrs.br]
#
# in order to build the toolchain, we need some basic tools:
# build-essential flex bison libgmp3-dev libmpc-dev libmpfr-dev autoconf
# texinfo libncurses5-dev gawk libtool zlib1g-dev 
#
# You don't need to run this script as root. Before running this script, create the
# /usr/local/avr directory and set the owner of this toolchain to your
# default user or a system admin, if you're the one:
# sudo chown user:user /usr/local/avr
# Then just run this script. After completion, add the tools directory to the PATH
# environment variable (export $PATH:=$PATH:/usr/local/avr/gcc/bin).
# alternatively, the compiler may be left anywhere in the user home directory. Also,
# create a symbolic link in the compiler directory (gcc-13.2.0 -> gcc) to support
# multiple versions of the toolchain.

set -o xtrace

binutils_base="binutils-2.41"
gcc_base="gcc-13.2.0"
avrlibc_base="avr-libc-2.1.0"
avrdude_base="avrdude-6.4"

root_dir=`pwd`
usr_local_dir="/usr/local"

TARGET=avr
PREFIX=${usr_local_dir}/$TARGET/${gcc_base}
BUILD=i686-linux-gnu

# setup our toolchain new path
export PATH=$PREFIX/bin:$PATH

dl_dir="${root_dir}/download"
src_dir="${root_dir}/source"
bld_dir="${root_dir}/build"
install_dir="${root_dir}/install"

mkdir ${src_dir}
mkdir ${bld_dir}
mkdir ${install_dir}
mkdir ${dl_dir}

# download all sources
cd $dl_dir
wget -c ftp://ftp.gnu.org/gnu/binutils/${binutils_base}.tar.gz
wget -c ftp://ftp.gnu.org/gnu/gcc/${gcc_base}/${gcc_base}.tar.gz
wget -c http://download.savannah.gnu.org/releases/avr-libc/${avrlibc_base}.tar.bz2
wget -c http://download.savannah.gnu.org/releases/avrdude/${avrdude_base}.tar.gz 

# unpack everything
cd ${src_dir}
tar -zxvf ${dl_dir}/"${binutils_base}.tar.gz"
tar -zxvf ${dl_dir}/"${gcc_base}.tar.gz"
tar -jxvf ${dl_dir}/"${avrlibc_base}.tar.bz2"
tar -zxvf ${dl_dir}/"${avrdude_base}.tar.gz"

#
# build binutils
#
cd ${bld_dir}
mkdir ${binutils_base}
cd ${binutils_base}
${src_dir}/${binutils_base}/configure --prefix=$PREFIX --target=$TARGET --disable-nls
make -j2 all
make install

#
# build GCC
#
cd ${src_dir}/${gcc_base}/
./contrib/download_prerequisites

cd ${bld_dir}
mkdir ${gcc_base}-initial
cd ${gcc_base}-initial
${src_dir}/${gcc_base}/configure --prefix=$PREFIX --target=$TARGET \
	--enable-languages=c,c++ --disable-nls --disable-libssp --with-dwarf2
make -j2 all
make install

#
# build avr-libc
#
cd ${bld_dir}
mkdir ${avrlibc_base}
cd ${avrlibc_base}
${src_dir}/${avrlibc_base}/configure --build=`./config.guess` --host=$TARGET --prefix=$PREFIX
make -j2 all
make install

#
# build avrdude
#
cd ${bld_dir}
mkdir ${avrdude_base}
cd ${avrdude_base}
${src_dir}/${avrdude_base}/configure --prefix=$PREFIX
make -j2 all
make install