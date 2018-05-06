FROM alpine:latest

MAINTAINER m.boukazoula@itsolutions.dz

WORKDIR /
RUN apk --update add git python py-pip build-base automake libtool m4 autoconf libevent-dev openssl-dev c-ares-dev
RUN pip install docutils
RUN git clone https://github.com/pgbouncer/pgbouncer.git src

WORKDIR /bin
RUN ln -s ../usr/bin/rst2man.py rst2man

WORKDIR /src
RUN mkdir /pgbouncer
RUN git submodule init
RUN git submodule update
RUN ./autogen.sh
RUN	./configure --prefix=/pgbouncer --with-libevent=/usr/lib
RUN make
RUN make install
RUN ls -R /pgbouncer
VOLUME ["/etc/pgbouncer/pgbouncer.ini"]
RUN apk --update add libevent openssl c-ares
WORKDIR /
ADD entrypoint.sh ./
ENTRYPOINT ["./entrypoint.sh"]
