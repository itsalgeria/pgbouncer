FROM ubuntu
MAINTAINER m.benyoub@itsolutions.dz

#RUN (echo "deb http://archive.ubuntu.com/ubuntu/ trusty main restricted universe multiverse" > /etc/apt/sources.list && echo "deb http://archive.ubuntu.com/ubuntu/ trusty-updates main restricted universe multiverse" >> /etc/apt/sources.list && echo "deb http://archive.ubuntu.com/ubuntu/ trusty-backports main restricted universe multiverse" >> /etc/apt/sources.list && echo "deb http://archive.ubuntu.com/ubuntu/ trusty-security main restricted universe multiverse" >> /etc/apt/sources.list)
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install pgbouncer net-tools vim wget postgresql-client
ADD run.sh /usr/local/bin/run
RUN chmod +x /usr/local/bin/run
EXPOSE 6432
VOLUME ["/etc/pgbouncer/"]
CMD ["/usr/local/bin/run"]
