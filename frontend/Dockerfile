FROM node:18-slim AS builder

WORKDIR /app

# Скачиваем и устанавливаем зависимости вручную
RUN ARCH=$(dpkg --print-architecture) && \
    CODENAME=$(lsb_release -cs) && \
    MIRROR="http://cdn-fastly.deb.debian.org/debian" && \
    mkdir -p /tmp/debs && \
    cd /tmp/debs && \
    curl -fL "${MIRROR}/pool/main/p/python3.11/python3_3.11.2-1+b1_${ARCH}.deb" -o python3.deb 2>/dev/null || \
    curl -fL "${MIRROR}/pool/main/p/python3-defaults/python3_3.11.2-1+b1_${ARCH}.deb" -o python3.deb 2>/dev/null || true && \
    curl -fL "${MIRROR}/pool/main/m/make-dfsg/make_4.3-4.1_${ARCH}.deb" -o make.deb 2>/dev/null || true && \
    curl -fL "${MIRROR}/pool/main/g/gcc-12/g++_12.2.0-14_${ARCH}.deb" -o gpp.deb 2>/dev/null || true && \
    curl -fL "${MIRROR}/pool/main/c/ca-certificates/ca-certificates_20230311_all.deb" -o ca-certificates.deb 2>/dev/null || true && \
    (dpkg -i *.deb 2>/dev/null || apt-get install -f -y) && \
    apt-get update && \
    apt-get install -y --no-install-recommends python3 make g++ ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/debs

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
