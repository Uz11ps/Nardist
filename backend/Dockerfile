FROM ubuntu:22.04 AS builder

WORKDIR /app

# Устанавливаем зависимости через прямые ссылки на .deb пакеты из зеркала Yandex
# Используем Python для скачивания, так как curl еще не установлен
RUN mkdir -p /tmp/packages && \
    cd /tmp/packages && \
    python3 -c "import urllib.request; urllib.request.urlretrieve('https://mirror.yandex.ru/ubuntu/pool/main/c/curl/curl_7.81.0-1ubuntu1.21_amd64.deb', '/tmp/packages/curl.deb')" && \
    python3 -c "import urllib.request; urllib.request.urlretrieve('https://mirror.yandex.ru/ubuntu/pool/main/c/ca-certificates/ca-certificates_20241223_all.deb', '/tmp/packages/ca-certificates.deb')" && \
    python3 -c "import urllib.request; urllib.request.urlretrieve('https://mirror.yandex.ru/ubuntu/pool/main/o/openssl/libssl-dev_3.0.13-0ubuntu3_amd64.deb', '/tmp/packages/libssl-dev.deb')" && \
    python3 -c "import urllib.request; urllib.request.urlretrieve('https://mirror.yandex.ru/ubuntu/pool/main/p/python3-defaults/libpython3-all-dbg_3.13.7-1_amd64.deb', '/tmp/packages/libpython3-all-dbg.deb')" && \
    python3 -c "import urllib.request; urllib.request.urlretrieve('https://mirror.yandex.ru/ubuntu/pool/main/g/gcc-defaults/cpp-aarch64-linux-gnu_13.2.0-7ubuntu1_amd64.deb', '/tmp/packages/cpp-aarch64-linux-gnu.deb')" && \
    python3 -c "import urllib.request; urllib.request.urlretrieve('https://mirror.yandex.ru/ubuntu/pool/main/m/make-dfsg/make_3.81-8.2ubuntu3_amd64.deb', '/tmp/packages/make.deb')" && \
    python3 -c "import urllib.request; urllib.request.urlretrieve('https://mirror.yandex.ru/ubuntu/pool/main/l/libcurl4/libcurl4_7.81.0-1ubuntu1.21_amd64.deb', '/tmp/packages/libcurl4.deb')" && \
    python3 -c "import urllib.request; urllib.request.urlretrieve('https://mirror.yandex.ru/ubuntu/pool/main/o/openssl/openssl_3.0.13-0ubuntu3_amd64.deb', '/tmp/packages/openssl.deb')" && \
    python3 -c "import urllib.request; urllib.request.urlretrieve('https://mirror.yandex.ru/ubuntu/pool/main/l/libssl3/libssl3_3.0.13-0ubuntu3_amd64.deb', '/tmp/packages/libssl3.deb')" && \
    python3 -c "import urllib.request; urllib.request.urlretrieve('https://mirror.yandex.ru/ubuntu/pool/main/g/gcc-12/g++_12.3.0-1ubuntu1~22.04_amd64.deb', '/tmp/packages/g++.deb')" && \
    python3 -c "import urllib.request; urllib.request.urlretrieve('https://mirror.yandex.ru/ubuntu/pool/main/g/gcc-12/gcc_12.3.0-1ubuntu1~22.04_amd64.deb', '/tmp/packages/gcc.deb')" && \
    python3 -c "import urllib.request; urllib.request.urlretrieve('https://mirror.yandex.ru/ubuntu/pool/main/g/gcc-defaults/gcc_4%3a12.2.0-3ubuntu1_amd64.deb', '/tmp/packages/gcc-defaults.deb')" && \
    python3 -c "import urllib.request; urllib.request.urlretrieve('https://mirror.yandex.ru/ubuntu/pool/main/g/gcc-12/libstdc++-12-dev_12.3.0-1ubuntu1~22.04_amd64.deb', '/tmp/packages/libstdc++-12-dev.deb')" && \
    python3 -c "import urllib.request; urllib.request.urlretrieve('https://mirror.yandex.ru/ubuntu/pool/main/g/gcc-12/libgcc-12-dev_12.3.0-1ubuntu1~22.04_amd64.deb', '/tmp/packages/libgcc-12-dev.deb')" && \
    python3 -c "import urllib.request; urllib.request.urlretrieve('https://mirror.yandex.ru/ubuntu/pool/main/g/gcc-12/libgcc-s1_12.3.0-1ubuntu1~22.04_amd64.deb', '/tmp/packages/libgcc-s1.deb')" && \
    python3 -c "import urllib.request; urllib.request.urlretrieve('https://mirror.yandex.ru/ubuntu/pool/main/g/gcc-12/libstdc++6_12.3.0-1ubuntu1~22.04_amd64.deb', '/tmp/packages/libstdc++6.deb')" && \
    python3 -c "import urllib.request; urllib.request.urlretrieve('https://mirror.yandex.ru/ubuntu/pool/main/l/libcrypt1/libcrypt1_4.4.27-1_amd64.deb', '/tmp/packages/libcrypt1.deb')" && \
    python3 -c "import urllib.request; urllib.request.urlretrieve('https://mirror.yandex.ru/ubuntu/pool/main/l/libkrb5/libkrb5-3_1.19.2-2ubuntu0.4_amd64.deb', '/tmp/packages/libkrb5-3.deb')" && \
    python3 -c "import urllib.request; urllib.request.urlretrieve('https://mirror.yandex.ru/ubuntu/pool/main/z/zlib/zlib1g_1.2.11.dfsg-2ubuntu9.2_amd64.deb', '/tmp/packages/zlib1g.deb')" && \
    dpkg -i --force-depends /tmp/packages/*.deb || true && \
    rm -rf /tmp/packages && \
    curl -fsSL https://nodejs.org/dist/v18.20.4/node-v18.20.4-linux-x64.tar.xz -o /tmp/node.tar.xz && \
    tar -xJf /tmp/node.tar.xz -C /usr/local --strip-components=1 && \
    rm /tmp/node.tar.xz

# Копируем package.json для кэширования npm пакетов
COPY package*.json ./
COPY prisma ./prisma/

# Используем npm ci для быстрой установки (требует package-lock.json)
ENV npm_config_loglevel=error
RUN npm ci --legacy-peer-deps --prefer-offline --no-audit --progress=false --silent || \
    npm install --legacy-peer-deps --prefer-offline --no-audit --progress=false --silent

# Генерируем Prisma клиент (нужны все зависимости)
RUN npx prisma generate

# Копируем исходный код
COPY . .

# Собираем приложение
RUN npm run build

FROM ubuntu:22.04 AS production

WORKDIR /app

# Устанавливаем зависимости через прямые ссылки на .deb пакеты из зеркала Yandex
# Используем Python для скачивания, так как curl еще не установлен
RUN mkdir -p /tmp/packages && \
    cd /tmp/packages && \
    python3 -c "import urllib.request; urllib.request.urlretrieve('https://mirror.yandex.ru/ubuntu/pool/main/c/curl/curl_7.81.0-1ubuntu1.21_amd64.deb', '/tmp/packages/curl.deb')" && \
    python3 -c "import urllib.request; urllib.request.urlretrieve('https://mirror.yandex.ru/ubuntu/pool/main/c/ca-certificates/ca-certificates_20241223_all.deb', '/tmp/packages/ca-certificates.deb')" && \
    python3 -c "import urllib.request; urllib.request.urlretrieve('https://mirror.yandex.ru/ubuntu/pool/main/o/openssl/openssl_3.0.2-0ubuntu1.15_amd64.deb', '/tmp/packages/openssl.deb')" && \
    python3 -c "import urllib.request; urllib.request.urlretrieve('https://mirror.yandex.ru/ubuntu/pool/main/l/libcurl4/libcurl4_7.81.0-1ubuntu1.21_amd64.deb', '/tmp/packages/libcurl4.deb')" && \
    python3 -c "import urllib.request; urllib.request.urlretrieve('https://mirror.yandex.ru/ubuntu/pool/main/l/libssl3/libssl3_3.0.2-0ubuntu1.15_amd64.deb', '/tmp/packages/libssl3.deb')" && \
    dpkg -i --force-depends /tmp/packages/*.deb || true && \
    rm -rf /tmp/packages && \
    curl -fsSL https://nodejs.org/dist/v18.20.4/node-v18.20.4-linux-x64.tar.xz -o /tmp/node.tar.xz && \
    tar -xJf /tmp/node.tar.xz -C /usr/local --strip-components=1 && \
    rm /tmp/node.tar.xz

# Копируем только package.json для production зависимостей
COPY package*.json ./
COPY prisma ./prisma/

# Устанавливаем только production зависимости с оптимизацией
ENV npm_config_loglevel=error
RUN npm ci --omit=dev --legacy-peer-deps --prefer-offline --no-audit --progress=false --silent || \
    npm install --omit=dev --legacy-peer-deps --prefer-offline --no-audit --progress=false --silent

# Копируем собранное приложение и сгенерированный Prisma клиент
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules/.prisma ./node_modules/.prisma
COPY --from=builder /app/node_modules/@prisma ./node_modules/@prisma

EXPOSE 3000

CMD ["node", "dist/main"]
