FROM node:18-slim AS builder

WORKDIR /app

# Устанавливаем системные зависимости
RUN if [ -f /etc/apt/sources.list ]; then \
        sed -i 's|http://deb.debian.org|http://cdn-fastly.deb.debian.org|g' /etc/apt/sources.list; \
    fi && \
    if [ -d /etc/apt/sources.list.d ]; then \
        find /etc/apt/sources.list.d -name "*.list" -exec sed -i 's|http://deb.debian.org|http://cdn-fastly.deb.debian.org|g' {} \; || true; \
    fi && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 \
    make \
    g++ \
    ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

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
