#!/bin/bash
set -e
mkdir -p /tmp/packages
cd /tmp/packages

# Скачиваем все необходимые пакеты из зеркала Yandex
wget https://mirror.yandex.ru/ubuntu/pool/main/c/curl/curl_7.81.0-1ubuntu1.21_amd64.deb
wget https://mirror.yandex.ru/ubuntu/pool/main/c/ca-certificates/ca-certificates_20241223_all.deb
wget https://mirror.yandex.ru/ubuntu/pool/main/o/openssl/openssl_3.0.13-0ubuntu3_amd64.deb
wget https://mirror.yandex.ru/ubuntu/pool/main/o/openssl/libssl-dev_3.0.13-0ubuntu3_amd64.deb
wget https://mirror.yandex.ru/ubuntu/pool/main/m/make-dfsg/make_3.81-8.2ubuntu3_amd64.deb

# Устанавливаем пакеты
dpkg -i --force-depends *.deb || true
apt-get install -f -y
rm -rf /tmp/packages