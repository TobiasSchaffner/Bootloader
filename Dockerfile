FROM debian:stable
MAINTAINER Tobias Schaffner <tobiasschaffner87@outlook.com>

ENV USER root
ENV HOME /root

RUN apt-get update
RUN apt-get install -y gcc g++ make bison flex libgmp-dev libmpfr-dev mpc \
                       texinfo wget bzip2 binutils-dev

WORKDIR src
RUN wget ftp://ftp.gnu.org/gnu/binutils/binutils-2.28.tar.gz
RUN wget ftp://ftp.gnu.org/gnu/gcc/gcc-6.3.0/gcc-6.3.0.tar.gz
RUN wget http://ftp.gnu.org/gnu/texinfo/texinfo-6.3.tar.gz

RUN for file in *; do tar -zxvf $file; rm $file; done;

RUN cd gcc-* && contrib/download_prerequisites

ENV PREFIX "$HOME/opt/cross"
ENV TARGET i686-elf
ENV PATH "$PREFIX/bin:$PATH"

WORKDIR build-binutils
RUN ../binutils-*/configure --target=$TARGET --prefix="$PREFIX" \
                                --with-sysroot --disable-nls --disable-werror
RUN make
RUN make install

WORKDIR ../build-gcc
RUN ../gcc-*/configure --target=$TARGET --prefix="$PREFIX" --disable-nls \
                       --enable-languages=c,c++ --without-headers
RUN make all-gcc
RUN make all-target-libgcc
RUN make install-gcc
RUN make install-target-libgcc

RUN export PATH="$HOME/opt/cross/bin:$PATH"

WORKDIR /root
ADD bootloader bootloader

RUN apt-get install -y nasm qemu coreutils
RUN mkdir build
RUN nasm -felf32 bootloader/boot.asm -o build/boot.o
RUN i686-elf-gcc -c bootloader/kernel.c -o build/kernel.o -std=gnu99 \
    -ffreestanding -O2 -Wall -Wextra
RUN i686-elf-gcc -T bootloader/linker.ld -o myos.bin -ffreestanding -O2 \
    -nostdlib build/boot.o build/kernel.o -lgcc

ENTRYPOINT ["/bin/bash"]
