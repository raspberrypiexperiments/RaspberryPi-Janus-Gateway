# RaspberryPi-Janus-Gateway

This repository contains Janus Gateway installation script. Janus Gateway package enables to be deployed in number of diffrent ways. The installation procedure defined in the installation script consists of <ins>__minimum__</ins>
steps to enable Echo Test and Streaming plugins over HTTPS protocol on Raspberry Pi.

## Known supported Raspberry Pi

* Raspberry Pi 3B,
* Raspberry Pi 4B.

## Installation

To install Janus Gateway run:

```bash
~ $ git clone --recurse-submodules -j4 https://github.com/raspberrypiexperiments/RaspberryPi-Janus-Gateway.git
~ $ cd RaspberryPi-Janus-Gateway
RaspberryPi-Janus-Gateway/~ $ make install 
```

## Uninstallation

To uninstall Janus Gateway run:

```bash
RaspberryPi-Janus-Gateway/~ $ make uninstall
RaspberryPi-Janus-Gateway/~ $ cd ..
~ $ rm -rf RaspberryPi-Janus-Gateway
```

## License

MIT License

Copyright (c) 2021 Marcin Sielski <marcin.sielski@gmail.com>
