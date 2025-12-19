#!/bin/bash
set -e
mkdir -p /tmp/packages
cd /tmp/packages
wget https://mirror.yandex.ru/ubuntu/pool/main/c/curl/curl_7.81.0-1ubuntu1.21_amd64.deb
wget https://mirror.yandex.ru/ubuntu/pool/main/p/python3-defaults/libpython3-all-dbg_3.13.7-1_amd64.deb
dpkg -i --force-depends *.deb || true
apt-get install -f -y
rm -rf /tmp/packages