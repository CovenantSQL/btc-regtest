FROM ubuntu:16.04

### Install dependencies
RUN apt-get update && apt-get install --yes \
    software-properties-common \
    build-essential autoconf libtool pkg-config \
    libboost-all-dev libevent-dev libssl-dev \
    bsdmainutils git tar wget \
 && rm -rf /var/lib/apt/lists/*

### Copy files
COPY data /root/regtest/data
COPY src  /root/regtest/src

### Install Berkeley DB 4.8 from source
#WORKDIR /root/regtest/src
#RUN wget -qO- http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz | tar -vxz

WORKDIR /root/regtest/src/db-4.8.30.NC/build_unix
RUN ../dist/configure --disable-shared --enable-cxx --prefix=/usr/local --with-pic
RUN make -j4 && make install
RUN echo "/usr/local/lib" >>/etc/ld.so.conf.d/local.conf && ldconfig

WORKDIR /root/regtest/src
RUN rm -rf ./db-4.8.30.NC

### Install bitcoin v0.16.0 from source
#WORKDIR /root/regtest/src
#RUN git clone https://github.com/bitcoin/bitcoin.git

WORKDIR /root/regtest/src/bitcoin
RUN git checkout -b v0.16.0
RUN ./autogen.sh
RUN ./configure
RUN make -j4 && make install 

# WORKDIR /root/regtest/src
#RUN rm -rf ./bitcoin

WORKDIR /root/regtest
EXPOSE 12001
CMD ["/usr/bin/env","bash"]
