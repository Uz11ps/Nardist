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

COPY package*.json ./
# Используем npm ci для быстрой установки (требует package-lock.json)
ENV npm_config_loglevel=error
RUN npm ci --prefer-offline --no-audit --progress=false --silent || \
    npm install --legacy-peer-deps --prefer-offline --no-audit --progress=false --silent

COPY . .
RUN npm run build

FROM nginx:latest

COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
