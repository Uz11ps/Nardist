FROM node:18-slim AS builder

WORKDIR /app

# Скачиваем пакеты напрямую через curl с реальными ссылками
RUN ARCH=$(dpkg --print-architecture) && \
    MIRROR="http://cdn-fastly.deb.debian.org/debian" && \
    mkdir -p /tmp/packages && \
    cd /tmp/packages && \
    apt-get update && \
    apt-cache show python3 make g++ ca-certificates > /tmp/pkg-info.txt && \
    for pkg in python3 make g++ ca-certificates; do \
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
