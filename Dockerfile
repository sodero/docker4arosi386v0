FROM debian:bullseye

RUN export DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y git gcc g++ make gawk bison flex bzip2 netpbm autoconf automake libx11-dev libxext-dev libc6-dev liblzo2-dev libxxf86vm-dev libpng-dev gcc-multilib libsdl1.2-dev byacc python3-mako libxcursor-dev cmake genisoimage dh-make yasm curl zsh libmpc-dev

WORKDIR /opt
RUN mkdir portssources

ADD https://mirror-hk.koddos.net/libreboot/misc/acpica/acpica-unix-20230331.tar.gz portssources/acpica-unix-20230331.tar.gz
ADD https://ftp.acc.umu.se/mirror/gnu.org/gnu/mpc/mpc-1.3.1.tar.gz portssources/mpc-1.3.1.tar.gz

RUN git clone -b alt-abiv0 https://github.com/deadwood2/AROS.git AROS
RUN echo "1" | AROS/scripts/rebuild.sh
RUN echo "3" | AROS/scripts/rebuild.sh

RUN mkdir bin
COPY bin/uname bin

#RUN $(cd ppc-amigaos/bin; for f in ppc-amigaos-*; do ln -s $f $(echo $f | sed -e 's/ppc-amigaos-//') ; done)

ENV LHAFLAGS=ao5
