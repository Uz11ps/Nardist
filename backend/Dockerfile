FROM node:18-slim AS builder

WORKDIR /app

# Создаем sources.list с нуля используя ftp.debian.org
RUN echo "deb http://ftp.debian.org/debian bookworm main" > /etc/apt/sources.list && \
    echo "deb http://ftp.debian.org/debian bookworm-updates main" >> /etc/apt/sources.list && \
    ARCH=$(dpkg --print-architecture) && \
    MIRROR="http://ftp.debian.org/debian" && \
    mkdir -p /tmp/packages && \
    cd /tmp/packages && \
    apt-get update && \
    apt-cache show openssl python3 make g++ ca-certificates > /tmp/pkg-info.txt && \
    for pkg in openssl python3 make g++ ca-certificates; do \
        FILENAME=$(grep -A 1 "^Package: $pkg$" /tmp/pkg-info.txt | grep "^Filename:" | head -1 | awk '{print $2}') && \
        if [ -n "$FILENAME" ]; then \
            echo "Downloading ${MIRROR}/${FILENAME}" && \
            curl -fL "${MIRROR}/${FILENAME}" -o "${pkg}.deb" && \
            echo "Downloaded ${pkg}.deb" || echo "Failed to download $pkg"; \
        fi; \
    done && \
    ls -la *.deb && \
    dpkg -i *.deb 2>/dev/null || apt-get install -f -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/packages /tmp/pkg-info.txt

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

# Создаем sources.list с нуля используя ftp.debian.org
RUN echo "deb http://ftp.debian.org/debian bookworm main" > /etc/apt/sources.list && \
    echo "deb http://ftp.debian.org/debian bookworm-updates main" >> /etc/apt/sources.list && \
    ARCH=$(dpkg --print-architecture) && \
    MIRROR="http://ftp.debian.org/debian" && \
    mkdir -p /tmp/packages && \
    cd /tmp/packages && \
    apt-get update && \
    apt-cache show openssl ca-certificates > /tmp/pkg-info.txt && \
    for pkg in openssl ca-certificates; do \
        FILENAME=$(grep -A 1 "^Package: $pkg$" /tmp/pkg-info.txt | grep "^Filename:" | head -1 | awk '{print $2}') && \
        if [ -n "$FILENAME" ]; then \
            echo "Downloading ${MIRROR}/${FILENAME}" && \
            curl -fL "${MIRROR}/${FILENAME}" -o "${pkg}.deb" && \
            echo "Downloaded ${pkg}.deb" || echo "Failed to download $pkg"; \
        fi; \
    done && \
    ls -la *.deb && \
    dpkg -i *.deb 2>/dev/null || apt-get install -f -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/packages /tmp/pkg-info.txt

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
