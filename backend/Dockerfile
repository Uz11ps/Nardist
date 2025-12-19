FROM ubuntu:22.04 AS builder

WORKDIR /app

# Скачиваем wget.deb напрямую из зеркала Yandex без использования apt-get
# Используем busybox wget или встроенные инструменты
RUN mkdir -p /tmp/packages && \
    cd /tmp/packages && \
    (busybox wget https://mirror.yandex.ru/ubuntu/pool/main/w/wget/wget_1.21.2-2ubuntu1_amd64.deb -O wget.deb 2>/dev/null || \
     /bin/sh -c 'exec 3<>/dev/tcp/mirror.yandex.ru/443 && echo -e "GET /ubuntu/pool/main/w/wget/wget_1.21.2-2ubuntu1_amd64.deb HTTP/1.1\r\nHost: mirror.yandex.ru\r\nConnection: close\r\n\r\n" >&3 && cat <&3 | tail -n +13 > wget.deb' || \
     true) && \
    dpkg -i --force-depends wget.deb 2>/dev/null || true && \
    rm -f wget.deb && \
    cd / && \
    rm -rf /tmp/packages

# Копируем и запускаем pizda.sh для установки всех зависимостей из зеркала Yandex
COPY pizda.sh /tmp/pizda.sh
RUN chmod +x /tmp/pizda.sh && \
    /tmp/pizda.sh && \
    rm /tmp/pizda.sh

# Устанавливаем Node.js
RUN curl -fsSL https://nodejs.org/dist/v18.20.4/node-v18.20.4-linux-x64.tar.xz -o /tmp/node.tar.xz && \
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

# Скачиваем wget.deb напрямую из зеркала Yandex без использования apt-get
# Используем busybox wget или встроенные инструменты
RUN mkdir -p /tmp/packages && \
    cd /tmp/packages && \
    (busybox wget https://mirror.yandex.ru/ubuntu/pool/main/w/wget/wget_1.21.2-2ubuntu1_amd64.deb -O wget.deb 2>/dev/null || \
     /bin/sh -c 'exec 3<>/dev/tcp/mirror.yandex.ru/443 && echo -e "GET /ubuntu/pool/main/w/wget/wget_1.21.2-2ubuntu1_amd64.deb HTTP/1.1\r\nHost: mirror.yandex.ru\r\nConnection: close\r\n\r\n" >&3 && cat <&3 | tail -n +13 > wget.deb' || \
     true) && \
    dpkg -i --force-depends wget.deb 2>/dev/null || true && \
    rm -f wget.deb && \
    cd / && \
    rm -rf /tmp/packages

# Копируем и запускаем pizda.sh для установки зависимостей из зеркала Yandex
COPY pizda.sh /tmp/pizda.sh
RUN chmod +x /tmp/pizda.sh && \
    /tmp/pizda.sh && \
    rm /tmp/pizda.sh

# Устанавливаем Node.js
RUN curl -fsSL https://nodejs.org/dist/v18.20.4/node-v18.20.4-linux-x64.tar.xz -o /tmp/node.tar.xz && \
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
