FROM node:18-slim AS builder

WORKDIR /app

# Устанавливаем зависимости для сборки
RUN echo 'Acquire::http::Timeout "10";' > /etc/apt/apt.conf.d/99timeout && \
    echo 'Acquire::ftp::Timeout "10";' >> /etc/apt/apt.conf.d/99timeout && \
    apt-get update -qq --allow-releaseinfo-change && \
    apt-get install -y --no-install-recommends --fix-missing \
    python3 \
    make \
    g++ \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /etc/apt/apt.conf.d/99timeout

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
