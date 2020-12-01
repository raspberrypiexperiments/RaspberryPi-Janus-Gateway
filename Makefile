NUM_PROCESSORS = `grep -c ^processor /proc/cpuinfo`

dependecies:
	sudo apt update
	sudo apt upgrade -y
	sudo apt install -y libjansson-dev libconfig-dev libssl-dev libmicrohttpd-dev libcurl4-openssl-dev libglib2.0-dev libgirepository1.0-dev
	sudo apt install -y autoconf automake autogen libtool gengetopt
	cd janus-gateway && git checkout v0.10.8

install: dependecies
	#rm -rf libnice
	#git clone https://gitlab.freedesktop.org/libnice/libnice
	#cd libnice && meson --prefix=/usr/local build && ninja -C build && sudo ninja -C build install
	#rm -rf libnice
	#rm -rf v2.2.0.tar.gz
	#wget https://github.com/cisco/libsrtp/archive/v2.2.0.tar.gz
	#rm -rf libsrtp-2.2.0
	#tar xfv v2.2.0.tar.gz
	#rm -rf v2.2.0.tar.gz
	#cd libsrtp-2.2.0 && ./configure --prefix=/usr/local --enable-openssl --disable-aes-gcm && make -j$(NUM_PROCESSORS) shared_library && sudo make install
	#rm -rf libsrtp-2.2.0
	#rm -rf janus-gateway
	#git clone https://github.com/meetecho/janus-gateway.git
	
	patch -p1 < 0001_janus.transport.http.jcfg.sample.patch
	cd janus-gateway && sh autogen.sh && ./configure --prefix=/opt/janus && make -j$(NUM_PROCESSORS) && sudo make install && sudo make configs
	rm -rf janus-gateway
	sudo openssl req -x509 -newkey rsa:4096 -config cert.cfg -keyout /opt/janus/etc/janus/key.pem -out /opt/janus/etc/janus/cert.pem -days 365 -nodes
	sudo chown $$USER:$$USER /opt/janus/etc/janus/key.pem
	sudo chown $$USER:$$USER /opt/janus/etc/janus/cert.pem
	sudo cp janus.service /etc/systemd/system
	sudo systemctl enable janus.service
	sudo systemctl start janus.service
	sleep 3
	sudo systemctl status janus.service

uninstall: dependecies
	sudo systemctl daemon-reload
	sudo systemctl stop janus.service
	sudo systemctl disable janus.service || true
	sudo rm -rf /etc/systemd/system/janus.service
	#rm -rf janus-gateway
	#git clone https://github.com/meetecho/janus-gateway.git
	patch -p1 < 0001_janus.transport.http.jcfg.sample.patch
	cd janus-gateway && sh autogen.sh && ./configure --prefix=/opt/janus && sudo make uninstall
	#rm -rf janus-gateway
	#rm -rf libsrtp-2.2.0
	#wget https://github.com/cisco/libsrtp/archive/v2.2.0.tar.gz
	#tar xfv v2.2.0.tar.gz
	#rm -rf v2.2.0.tar.gz
	#cd libsrtp-2.2.0 && ./configure --prefix=/usr/local --enable-openssl --disable-aes-gcm && sudo make uninstall
	#rm -rf libsrtp-2.2.0
	#rm -rf libnice
	#git clone https://gitlab.freedesktop.org/libnice/libnice
	#cd libnice && meson --prefix=/usr/local build && ninja -C build && sudo ninja -C build uninstall
	#rm -rf libnice
	#rm -rf v2.2.0.tar.gz
