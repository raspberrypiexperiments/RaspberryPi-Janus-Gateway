NUM_PROCESSORS = `grep -c ^processor /proc/cpuinfo`

dependecies:
	sudo apt update
	sudo apt upgrade -y
	sudo apt install -y libjansson-dev libconfig-dev libssl-dev libmicrohttpd-dev libcurl4-openssl-dev libglib2.0-dev libgirepository1.0-dev
	sudo apt install -y autoconf automake autogen libtool gengetopt
	cd janus-gateway && git checkout v0.10.8

install: dependecies	
	patch -p1 < 0001_janus.transport.http.jcfg.sample.patch
	cd janus-gateway && sh autogen.sh && ./configure --prefix=/opt/janus && make -j$(NUM_PROCESSORS) && sudo make install && sudo make configs
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
	patch -p1 < 0001_janus.transport.http.jcfg.sample.patch
	cd janus-gateway && sh autogen.sh && ./configure --prefix=/opt/janus && sudo make uninstall
