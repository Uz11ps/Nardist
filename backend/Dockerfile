FROM node:18-slim AS builder

WORKDIR /app

# Устанавливаем системные зависимости
RUN sed -i 's|http://deb.debian.org|http://cdn-fastly.deb.debian.org|g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    openssl \
    python3 \
    make \
    g++ \
    ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

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
RUN sed -i 's|http://deb.debian.org|http://cdn-fastly.deb.debian.org|g' /etc/apt/sources.list && \
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
