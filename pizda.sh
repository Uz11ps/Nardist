#!/bin/bash
set -e
mkdir -p /tmp/packages
cd /tmp/packages
wget http://mirror.yandex.ru/ubuntu/pool/main/c/curl/curl_7.81.0-1ubuntu1.15_amd64.deb
wget http://mirror.yandex.ru/ubuntu/pool/main/l/libcurl4/libcurl4_7.81.0-1ubuntu1.15_amd64.deb
dpkg -i --force-depends *.deb || true
apt-get install -f -y
rm -rf /tmp/packages