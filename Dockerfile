FROM debian:stretch-slim
LABEL maintainer="stéphane BROSSE <steevebrush@gmail.com>"

ENV DEBIAN_FRONTEND noninteractive
ENV TIMEZONE Europe/Paris

RUN set -x && \
	buildDeps='cmake make gcc g++ git libssl-dev libcurl4-gnutls-dev libudev-dev libusb-dev python3-setuptools zlib1g-dev libboost-dev libboost-thread-dev libboost-system-dev libboost-atomic-dev libboost-regex-dev' && \
    apt-get -qq update && \
    apt-get -qq install $buildDeps && \
    apt-get -qq install -y python3-dev curl libusb-0.1-4 libcurl3-gnutls && \
    echo ${TIMEZONE} > /etc/timezone && \
    ln -fs /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && \
    dpkg-reconfigure tzdata -f noninteractive && \
	git clone --depth 2 https://github.com/domoticz/domoticz.git /src/domoticz && \
	cd /src/domoticz && \
	git fetch --unshallow && \
	git clone --depth 2 https://github.com/OpenZWave/open-zwave.git /src/open-zwave && \
	git clone --depth 2 https://github.com/mjg59/python-broadlink /src/python-broadlink && \
    cd /src/open-zwave && \
    make && \
    ln -s /src/open-zwave /src/open-zwave-read-only && \
    cd /src/python-broadlink && \
	python3 setup.py install && \
	mkdir /src/build && \
    cd /src/build && \
    cmake -DCMAKE_BUILD_TYPE=Release ../domoticz && \
    make && \
    make install && \
    apt-get -qq remove $buildDeps && \
    cp -r /src/domoticz/dzVents /opt/domoticz/ && \
    rm -rf /src && \
    apt-get -qq autoclean && \
    apt-get -qq autoremove && \
    rm -rf /var/lib/apt/lists/*

VOLUME /config

EXPOSE 9080

ENTRYPOINT ["/opt/domoticz/domoticz", "-dbase", "/config/domoticz.db", "-log", "/config/domoticz.log", "-sslwww", "0"]
CMD ["-www", "9080"]
