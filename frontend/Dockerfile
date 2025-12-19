FROM ubuntu:22.04 AS builder

WORKDIR /app

# Устанавливаем зависимости через правильную структуру Yandex зеркала
RUN echo "deb [trusted=yes] http://mirror.yandex.ru/ubuntu jammy main restricted universe multiverse" > /etc/apt/sources.list && \
    mkdir -p /var/lib/apt/lists/partial && \
    curl -fsSL http://mirror.yandex.ru/ubuntu/dists/jammy/InRelease -o /var/lib/apt/lists/mirror.yandex.ru_ubuntu_dists_jammy_InRelease && \
    curl -fsSL http://mirror.yandex.ru/ubuntu/dists/jammy/main/binary-amd64/Packages.gz -o /tmp/Packages.gz && \
    gunzip -c /tmp/Packages.gz > /var/lib/apt/lists/mirror.yandex.ru_ubuntu_dists_jammy_main_binary-amd64_Packages && \
    rm /tmp/Packages.gz && \
    apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    python3 \
    make \
    g++ && \
    curl -fsSL https://nodejs.org/dist/v18.20.4/node-v18.20.4-linux-x64.tar.xz -o /tmp/node.tar.xz && \
    tar -xJf /tmp/node.tar.xz -C /usr/local --strip-components=1 && \
    rm /tmp/node.tar.xz && \
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
