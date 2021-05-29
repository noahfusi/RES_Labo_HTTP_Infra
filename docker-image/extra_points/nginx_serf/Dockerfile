FROM nginx:1.21.0
RUN apt-get update
RUN apt-get -y install wget
RUN apt-get -y install unzip
RUN cd /tmp
RUN wget https://releases.hashicorp.com/serf/0.8.2/serf_0.8.2_linux_amd64.zip
RUN unzip serf_0.8.2_linux_amd64.zip
RUN mv serf /usr/local/bin/serf
COPY config/ /etc/nginx/
RUN apt-get -y install systemd
COPY scripts/ /usr/local/bin/
COPY startup_scripts/ /

