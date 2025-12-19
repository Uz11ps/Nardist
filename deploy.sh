#!/bin/bash

set -e

# Определяем команду docker compose (новая версия) или docker-compose (старая версия)
if command -v docker &> /dev/null && docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
elif command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
else
    echo "❌ Error: docker compose or docker-compose not found!"
    echo "Please install Docker Compose: https://docs.docker.com/compose/install/"
    exit 1
fi

echo "🚀 Starting deployment..."
echo "📝 Using: $DOCKER_COMPOSE"

# Load environment variables
if [ -f .env ]; then
    # Загружаем переменные из .env файла
    set -a
    source .env
    set +a
    echo "✅ Environment variables loaded from .env"
else
    echo "❌ Error: .env file not found!"
    echo "Please create .env file with required variables"
    exit 1
fi

# Check if domain is set
if [ -z "$DOMAIN_NAME" ]; then
    echo "❌ Error: DOMAIN_NAME not set in .env file!"
    exit 1
fi

echo "📦 Pulling base images (postgres, redis, nginx, certbot)..."
$DOCKER_COMPOSE -f docker-compose.prod.yml pull postgres redis nginx certbot || echo "⚠️  Some base images pull failed, will use cached versions"

# Проверяем, есть ли готовые образы в GitHub Container Registry
if [ -n "$BACKEND_IMAGE" ] && [ "$BACKEND_IMAGE" != "nardist-backend:latest" ] && [ -n "$FRONTEND_IMAGE" ] && [ "$FRONTEND_IMAGE" != "nardist-frontend:latest" ]; then
    echo "📥 Attempting to pull pre-built images from GitHub Container Registry..."
    
    BACKEND_PULLED=false
    FRONTEND_PULLED=false
    
    if docker pull ${BACKEND_IMAGE} 2>/dev/null; then
        echo "✅ Backend image pulled successfully"
        BACKEND_PULLED=true
    else
        echo "⚠️  Backend image not found in registry, will build locally"
    fi
    
    if docker pull ${FRONTEND_IMAGE} 2>/dev/null; then
        echo "✅ Frontend image pulled successfully"
        FRONTEND_PULLED=true
    else
        echo "⚠️  Frontend image not found in registry, will build locally"
    fi
    
    # Если оба образа скачаны, используем их, иначе собираем недостающие
    if [ "$BACKEND_PULLED" = true ] && [ "$FRONTEND_PULLED" = true ]; then
        echo "✅ Using pre-built images from registry (much faster!)"
    else
        echo "🔨 Building missing images locally (this may take 5-10 minutes)..."
        export DOCKER_BUILDKIT=1
        export COMPOSE_DOCKER_CLI_BUILD=1
        
        if [ "$BACKEND_PULLED" = false ]; then
            echo "🔨 Building backend..."
            $DOCKER_COMPOSE -f docker-compose.prod.yml build backend
        fi
        
        if [ "$FRONTEND_PULLED" = false ]; then
            echo "🔨 Building frontend..."
            $DOCKER_COMPOSE -f docker-compose.prod.yml build frontend
        fi
    fi
else
    echo "🔨 Building application images locally (this may take 5-10 minutes)..."
    echo "💡 Tip: Set BACKEND_IMAGE=ghcr.io/uz11ps/nardist-backend:latest and FRONTEND_IMAGE=ghcr.io/uz11ps/nardist-frontend:latest in .env to use pre-built images"
    export DOCKER_BUILDKIT=1
    export COMPOSE_DOCKER_CLI_BUILD=1
    $DOCKER_COMPOSE -f docker-compose.prod.yml build --parallel backend frontend
fi

echo "🚀 Starting containers..."
$DOCKER_COMPOSE -f docker-compose.prod.yml up -d

echo "⏳ Waiting for services to be ready..."
# Ждем запуска базовых сервисов
echo "   Waiting for PostgreSQL..."
timeout=60
while [ $timeout -gt 0 ]; do
    if $DOCKER_COMPOSE -f docker-compose.prod.yml exec -T postgres pg_isready -U ${POSTGRES_USER:-nardist} > /dev/null 2>&1; then
        echo "   ✅ PostgreSQL is ready"
        break
    fi
    sleep 2
    timeout=$((timeout - 2))
done

echo "   Waiting for Redis..."
timeout=30
while [ $timeout -gt 0 ]; do
    if $DOCKER_COMPOSE -f docker-compose.prod.yml exec -T redis redis-cli ping > /dev/null 2>&1; then
        echo "   ✅ Redis is ready"
        break
    fi
    sleep 2
    timeout=$((timeout - 2))
done

echo "🗄️ Running database migrations..."
# Ждем, пока backend полностью запустится
sleep 5
$DOCKER_COMPOSE -f docker-compose.prod.yml exec -T backend npx prisma migrate deploy || echo "⚠️  Migration failed or already applied"

echo "🔒 Setting up SSL certificate..."
# Проверяем наличие сертификата в volume certbot_data
if ! $DOCKER_COMPOSE -f docker-compose.prod.yml exec -T certbot test -d /etc/letsencrypt/live/${DOMAIN_NAME} 2>/dev/null || \
   ! $DOCKER_COMPOSE -f docker-compose.prod.yml exec -T certbot test -f /etc/letsencrypt/live/${DOMAIN_NAME}/fullchain.pem 2>/dev/null; then
    echo "📝 Requesting SSL certificate..."
    echo "⚠️  Note: SSL certificate setup requires the domain to point to this server"
    echo "⚠️  Make sure DNS is configured before running this step"
    $DOCKER_COMPOSE -f docker-compose.prod.yml --profile ssl run --rm certbot certonly \
        --webroot \
        --webroot-path=/var/www/certbot \
        --email ${SSL_EMAIL} \
        --agree-tos \
        --no-eff-email \
        -d ${DOMAIN_NAME} \
        -d www.${DOMAIN_NAME} || echo "⚠️  SSL certificate request failed. You can set it up later."
    echo "🔄 Reloading Nginx..."
    $DOCKER_COMPOSE -f docker-compose.prod.yml exec nginx nginx -s reload 2>/dev/null || echo "⚠️  Nginx reload skipped (may not be running yet)"
else
    echo "✅ SSL certificate already exists"
fi

echo "🧹 Cleaning up unused Docker resources..."
docker system prune -f --volumes || true

echo "✅ Deployment completed successfully!"
echo "🌐 Your application is available at: https://${DOMAIN_NAME}"

