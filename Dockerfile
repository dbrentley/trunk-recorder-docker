# This docker file will download and build trunk-recorder from source.
# You could, of course, run all of these commands manually to compile :D
#
# https://github.com/robotastic/trunk-recorder
#
# @author: https://github.com/dbrentley
#
FROM ubuntu AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt upgrade -y
# putting these on different layers on purpose
RUN apt install -y cmake git build-essential binutils sudo gnuradio \
    libssl-dev libcurl4-gnutls-dev libcurl4-gnutls-dev pkg-config autoconf \
    libtool yasm texinfo vim libboost-all-dev libhackrf-dev liborc-0.4-dev \
    libgnuradio-osmosdr0.2.0 libgnuradio-uhd3.8.1 libuhd-dev

WORKDIR /root

RUN git clone https://github.com/robotastic/trunk-recorder.git && \
    cd trunk-recorder && mkdir build && cd build && \
    cmake .. && make && make install

# we built on ubuntu but the image will actually be using debian

FROM debian

RUN apt update && apt upgrade -y && apt install -y vim sudo

COPY --from=builder /root/trunk-recorder/build/trunk-recorder /usr/local/bin/
COPY --from=builder /usr/local/lib/ /usr/local/lib/
COPY --from=builder /usr/lib/x86_64-linux-gnu/ /usr/lib/x86_64-linux-gnu/
RUN ldconfig /usr/local/lib/trunk-recorder

RUN useradd -s /bin/bash -m scanmikey && yes scanmikey | passwd scanmikey && \
    echo "scanmikey ALL = (ALL) ALL" >> /etc/sudoers

WORKDIR /home/scanmikey
USER scanmikey

CMD ["/bin/bash"]

# build it: docker build -t trunk-recorder .
# run it:   docker run -it trunk-recorder
# login:    scanmikey/scanmikey
# profit:   trunk-recorder
