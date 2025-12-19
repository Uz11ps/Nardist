FROM node:18-slim AS builder

WORKDIR /app

# Устанавливаем зависимости для сборки
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 \
    make \
    g++ \
    && rm -rf /var/lib/apt/lists/*

COPY package*.json ./
# Используем npm ci для быстрой установки (требует package-lock.json)
ENV npm_config_loglevel=error
RUN npm ci --prefer-offline --no-audit --progress=false --silent || \
    npm install --legacy-peer-deps --prefer-offline --no-audit --progress=false --silent

COPY . .
RUN npm run build

FROM nginx:stable-slim

COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
