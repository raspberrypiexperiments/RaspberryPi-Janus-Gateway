# MIT License
#
# Copyright (c) 2021 Marcin Sielski <marcin.sielski@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

NUM_PROCESSORS = `grep -c ^processor /proc/cpuinfo`

dependecies:
	sudo apt update
	sudo apt upgrade -y
	sudo apt install -y libjansson-dev libconfig-dev libssl-dev libmicrohttpd-dev libcurl4-openssl-dev libglib2.0-dev libgirepository1.0-dev
	sudo apt install -y autoconf automake autogen libtool gengetopt
	cd janus-gateway && git checkout v0.10.8

install: dependecies	
	cd usrsctp && ./bootstrap && ./configure --prefix=/usr/local --disable-programs --disable-inet --disable-inet6 && make -j$(NUM_PROCESSORS) && sudo make install
	if ! patch -R -p1 -s -f --dry-run <0001_janus.transport.http.jcfg.sample.patch; then patch -p1 < 0001_janus.transport.http.jcfg.sample.patch; fi
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
	patch -p1 -R < 0001_janus.transport.http.jcfg.sample.patch
	cd janus-gateway && sh autogen.sh && ./configure --prefix=/opt/janus && sudo make uninstall
	cd usrsctp && ./bootstrap && ./configure --prefix=/usr/local --disable-programs --disable-inet --disable-inet6 && sudo make uninstall
