FROM node:18-slim AS builder

WORKDIR /app

# Устанавливаем необходимые зависимости для сборки
RUN echo 'Acquire::http::Timeout "10";' > /etc/apt/apt.conf.d/99timeout && \
    echo 'Acquire::ftp::Timeout "10";' >> /etc/apt/apt.conf.d/99timeout && \
    apt-get update -qq --allow-releaseinfo-change && \
    apt-get install -y --no-install-recommends --fix-missing \
    openssl \
    python3 \
    make \
    g++ \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /etc/apt/apt.conf.d/99timeout

# Устанавливаем зависимости для кэширования
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
RUN echo 'Acquire::http::Timeout "10";' > /etc/apt/apt.conf.d/99timeout && \
    echo 'Acquire::ftp::Timeout "10";' >> /etc/apt/apt.conf.d/99timeout && \
    apt-get update -qq --allow-releaseinfo-change && \
    apt-get install -y --no-install-recommends --fix-missing \
    openssl \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /etc/apt/apt.conf.d/99timeout

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
