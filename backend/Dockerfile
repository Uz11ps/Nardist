FROM ubuntu:22.04 AS builder

WORKDIR /app

# Проблема: в базовом образе нет python3, поэтому используем pizda.sh с wget
# Сначала устанавливаем только wget через стандартный apt (минимальная зависимость)
RUN apt-get update && \
    apt-get install -y --no-install-recommends wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

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

# Проблема: в базовом образе нет python3, поэтому используем pizda.sh с wget
# Сначала устанавливаем только wget через стандартный apt (минимальная зависимость)
RUN apt-get update && \
    apt-get install -y --no-install-recommends wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

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
