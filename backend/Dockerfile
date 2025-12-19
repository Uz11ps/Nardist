FROM node:18-slim AS builder

WORKDIR /app

# Скачиваем и устанавливаем зависимости вручную
RUN ARCH=$(dpkg --print-architecture) && \
    CODENAME=$(lsb_release -cs) && \
    MIRROR="http://cdn-fastly.deb.debian.org/debian" && \
    mkdir -p /tmp/debs && \
    cd /tmp/debs && \
    curl -fL "${MIRROR}/pool/main/o/openssl/openssl_3.0.11-1~deb12u2_${ARCH}.deb" -o openssl.deb 2>/dev/null || \
    curl -fL "${MIRROR}/pool/main/p/python3.11/python3_3.11.2-1+b1_${ARCH}.deb" -o python3.deb 2>/dev/null || \
    curl -fL "${MIRROR}/pool/main/p/python3-defaults/python3_3.11.2-1+b1_${ARCH}.deb" -o python3.deb 2>/dev/null || true && \
    curl -fL "${MIRROR}/pool/main/m/make-dfsg/make_4.3-4.1_${ARCH}.deb" -o make.deb 2>/dev/null || true && \
    curl -fL "${MIRROR}/pool/main/g/gcc-12/g++_12.2.0-14_${ARCH}.deb" -o gpp.deb 2>/dev/null || true && \
    curl -fL "${MIRROR}/pool/main/c/ca-certificates/ca-certificates_20230311_all.deb" -o ca-certificates.deb 2>/dev/null || true && \
    (dpkg -i *.deb 2>/dev/null || apt-get install -f -y) && \
    apt-get update && \
    apt-get install -y --no-install-recommends openssl python3 make g++ ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/debs

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

FROM node:18-slim AS production

WORKDIR /app

# Устанавливаем только необходимые runtime зависимости
RUN if [ -f /etc/apt/sources.list ]; then \
        sed -i 's|http://deb.debian.org|http://cdn-fastly.deb.debian.org|g' /etc/apt/sources.list; \
    fi && \
    if [ -d /etc/apt/sources.list.d ]; then \
        find /etc/apt/sources.list.d -name "*.list" -exec sed -i 's|http://deb.debian.org|http://cdn-fastly.deb.debian.org|g' {} \; || true; \
    fi && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    openssl \
    ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

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
