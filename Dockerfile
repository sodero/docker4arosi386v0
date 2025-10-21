FROM debian:trixie

RUN export DEBIAN_FRONTEND=noninteractive

RUN apt-get update

RUN apt-get install -y git gcc g++ make gawk bison flex bzip2 netpbm autoconf \
    automake libx11-dev libxext-dev libc6-dev liblzo2-dev libxxf86vm-dev \
    libpng-dev gcc-multilib libsdl1.2-dev byacc cmake genisoimage dh-make yasm \
    curl zsh libmpc-dev unzip python3-mako libxcursor-dev lhasa

WORKDIR /opt

RUN git clone --depth=1 https://github.com/sodero/lha.git && \
    cd lha && \
    aclocal && \
    autoheader && \
    automake -a && \
    autoconf && \
    ./configure CC=/usr/bin/cc && \
    make && \
    make install && \
    cd -

RUN git clone --depth=1 https://github.com/adtools/flexcat.git && \
    cd flexcat && \
    make bootstrap && \
    make && \
    cd -

RUN install flexcat/src/bin_unix/flexcat /usr/local/bin

RUN mkdir portssources

ADD https://mirror-hk.koddos.net/libreboot/misc/acpica/acpica-unix-20230331.tar.gz portssources/acpica-unix-20230331.tar.gz
ADD https://ftp.acc.umu.se/mirror/gnu.org/gnu/mpc/mpc-1.3.1.tar.gz portssources/mpc-1.3.1.tar.gz
ADD http://aminet.net/dev/mui/MCC_TheBar-26.22.lha portssource/MCC_TheBar-26.22.lha
ADD https://download-mirror.savannah.gnu.org/releases/freetype/ftdmo2103.zip portssources/ftdmo2103.zip
ADD https://pub.sortix.org/mirror/libjpeg/jpegsrc.v9e.tar.gz portssources/jpegsrc.v9e.tar.gz

RUN git clone --depth 1 -b alt-abiv0 https://github.com/deadwood2/AROS.git AROS

RUN echo "1" | AROS/scripts/rebuild.sh i386
RUN echo "3" | AROS/scripts/rebuild.sh i386
RUN echo "6" | AROS/scripts/rebuild.sh i386

RUN lha e portssource/MCC_TheBar-26.22.lha
RUN cp MCC_TheBar/Developer/C/include/mui/TheBar_mcc.h /opt/alt-abiv0-linux-i386-d/bin/linux-i386/gen/include/mui
RUN mv MCC_TheBar/Developer/C/include/mui/TheBar_mcc.h /opt/alt-abiv0-linux-i386-d/bin/linux-i386/AROS/Development/include/mui
RUN rm -rf MCC_TheBar portssource

RUN mkdir bin
COPY bin/* bin/
RUN cd bin && for f in /opt/toolchain-alt-abiv0-i386/i386-aros-*; do ln -s $f $(echo $f | sed -e 's/.*i386-aros-//') 2> /dev/null; done

ENV PATH="/opt/bin:$PATH"
ENV LHAFLAGS=ao5
ENV DD=..

RUN git clone --depth=1 https://github.com/sodero/InstallerLG.git && \
    make -C InstallerLG/build

RUN mkdir native && \
    cp InstallerLG/build/Installer native

RUN echo 'alias ll="ls -la"' >> ~/.bashrc
