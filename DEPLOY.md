# Полное руководство по развертыванию Nardist на Ubuntu 22.04

Это подробное руководство поможет вам развернуть приложение Nardist на чистом сервере Ubuntu 22.04 с нуля.

## 📋 Требования

- Сервер с Ubuntu 22.04 LTS
- Минимум 2 GB RAM (рекомендуется 4 GB)
- Минимум 20 GB свободного места на диске
- Root доступ или пользователь с sudo правами
- Доменное имя, настроенное на IP-адрес сервера (для SSL)

## 🚀 Шаг 1: Подключение к серверу

Подключитесь к серверу по SSH:

```bash
ssh root@your-server-ip
# или
ssh your-username@your-server-ip
```

## 🔧 Шаг 2: Инициализация сервера

### 2.1. Обновление системы

```bash
sudo apt update
sudo apt upgrade -y
```

### 2.2. Установка необходимых пакетов

```bash
sudo apt install -y curl git ufw
```

### 2.3. Установка Docker

```bash
# Скачиваем и запускаем официальный скрипт установки Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
rm get-docker.sh

# Добавляем текущего пользователя в группу docker (чтобы не использовать sudo)
sudo usermod -aG docker $USER

# Проверяем установку
docker --version
```

**Важно:** После добавления пользователя в группу docker нужно выйти и зайти заново, или выполнить:
```bash
newgrp docker
```

### 2.4. Установка Docker Compose

Docker Compose V2 входит в состав Docker Desktop, но для сервера нужно установить его отдельно:

```bash
# Проверяем, установлен ли docker compose (V2)
docker compose version

# Если команда не найдена, устанавливаем Docker Compose V2
sudo apt install -y docker-compose-plugin

# Проверяем установку
docker compose version
```

### 2.5. Настройка файрвола

```bash
# Разрешаем SSH (важно сделать первым!)
sudo ufw allow 22/tcp

# Разрешаем HTTP и HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Включаем файрвол
sudo ufw --force enable

# Проверяем статус
sudo ufw status
```

## 📥 Шаг 3: Клонирование репозитория

```bash
# Создаем директорию для приложения
sudo mkdir -p /opt/nardist
sudo chown -R $USER:$USER /opt/nardist

# Переходим в директорию
cd /opt/nardist

# Клонируем репозиторий
git clone https://github.com/Uz11ps/Nardist.git .

# Или если репозиторий приватный, используйте SSH:
# git clone git@github.com:Uz11ps/Nardist.git .
```

## ⚙️ Шаг 4: Настройка переменных окружения

### 4.1. Создание файла .env

```bash
cd /opt/nardist
nano .env
```

### 4.2. Содержимое файла .env

Скопируйте и заполните следующий шаблон:

```env
# Домен (уже настроен на nardist.online)
DOMAIN_NAME=nardist.online
SSL_EMAIL=your-email@example.com

# База данных PostgreSQL
POSTGRES_USER=nardist
POSTGRES_PASSWORD=your_strong_password_here
POSTGRES_DB=nardist_db

# Backend
JWT_SECRET=your_jwt_secret_key_min_32_chars
TELEGRAM_BOT_TOKEN=your_telegram_bot_token
FRONTEND_URL=https://nardist.online

# Frontend
VITE_API_URL=https://nardist.online
VITE_WS_URL=https://nardist.online

# Docker образы (опционально, для использования предсобранных образов)
# BACKEND_IMAGE=ghcr.io/uz11ps/nardist-backend:latest
# FRONTEND_IMAGE=ghcr.io/uz11ps/nardist-frontend:latest
```

**Важно:**
- Домен: `nardist.online` (уже настроен)
- Замените `your-email@example.com` на ваш реальный email (для SSL)
- Сгенерируйте сильный пароль для PostgreSQL (минимум 16 символов)
- Сгенерируйте JWT_SECRET (минимум 32 символа): `openssl rand -base64 32`
- Получите TELEGRAM_BOT_TOKEN от @BotFather в Telegram

### 4.3. Сохранение файла

В nano: нажмите `Ctrl+O` для сохранения, затем `Enter`, затем `Ctrl+X` для выхода.

## 🌐 Шаг 5: Настройка DNS для nardist.online

Перед продолжением убедитесь, что DNS записи для домена `nardist.online` настроены:

1. Зайдите в панель управления вашего домена `nardist.online`
2. Создайте A-запись:
   - Имя: `@` (или оставьте пустым)
   - Значение: IP-адрес вашего сервера
   - TTL: 3600 (или автоматически)
3. Создайте A-запись для www:
   - Имя: `www`
   - Значение: IP-адрес вашего сервера
   - TTL: 3600

Проверьте, что DNS записи применены:

```bash
# Проверка DNS (может занять до 24 часов, обычно 1-2 часа)
dig +short nardist.online
dig +short www.nardist.online

# Оба должны вернуть IP-адрес вашего сервера
```

## 🚀 Шаг 6: Развертывание приложения

### 6.1. Делаем скрипт деплоя исполняемым

```bash
cd /opt/nardist
chmod +x deploy.sh
```

### 6.2. Запускаем деплой

```bash
./deploy.sh
```

Скрипт выполнит следующие действия:
1. Проверит наличие Docker и Docker Compose
2. Загрузит переменные окружения из `.env`
3. Скачает базовые образы (PostgreSQL, Redis, Nginx)
4. Соберет образы backend и frontend (или попытается скачать предсобранные)
5. Запустит все контейнеры
6. Применит миграции базы данных
7. Настроит SSL сертификат (если DNS настроен)

**Время выполнения:** 5-15 минут в зависимости от скорости интернета и сервера.

### 6.3. Если что-то пошло не так

Если скрипт завершился с ошибкой, проверьте логи:

```bash
# Логи всех контейнеров
docker compose -f docker-compose.prod.yml logs

# Логи конкретного сервиса
docker compose -f docker-compose.prod.yml logs backend
docker compose -f docker-compose.prod.yml logs frontend
docker compose -f docker-compose.prod.yml logs postgres
```

## 🔒 Шаг 7: Настройка SSL (если не настроилось автоматически)

Если SSL сертификат не был получен автоматически:

### 7.1. Убедитесь, что DNS настроен

```bash
# Проверка
dig +short nardist.online
```

### 7.2. Получите SSL сертификат вручную

```bash
cd /opt/nardist

# Загружаем переменные окружения
source .env

# Запускаем certbot
docker compose -f docker-compose.prod.yml run --rm certbot certonly \
    --webroot \
    --webroot-path=/var/www/certbot \
    --email ${SSL_EMAIL} \
    --agree-tos \
    --no-eff-email \
    -d ${DOMAIN_NAME} \
    -d www.${DOMAIN_NAME}
```

### 7.3. Проверьте конфигурацию Nginx

Конфигурация уже настроена на `nardist.online` в файле `nginx/conf.d/default.conf`. Если нужно изменить домен, отредактируйте файл:

```bash
nano nginx/conf.d/default.conf
```

Убедитесь, что указаны правильные значения:
- `server_name nardist.online www.nardist.online;`
- `ssl_certificate /etc/letsencrypt/live/nardist.online/fullchain.pem;`
- `ssl_certificate_key /etc/letsencrypt/live/nardist.online/privkey.pem;`

### 7.4. Перезапустите Nginx

```bash
docker compose -f docker-compose.prod.yml restart nginx
```

## ✅ Шаг 8: Проверка работы

### 8.1. Проверка статуса контейнеров

```bash
docker compose -f docker-compose.prod.yml ps
```

Все контейнеры должны быть в статусе `Up`.

### 8.2. Проверка логов

```bash
# Backend
docker compose -f docker-compose.prod.yml logs backend --tail=50

# Frontend
docker compose -f docker-compose.prod.yml logs frontend --tail=50

# Nginx
docker compose -f docker-compose.prod.yml logs nginx --tail=50
```

### 8.3. Проверка в браузере

Откройте в браузере:
- `https://nardist.online` - должен открыться frontend
- `https://nardist.online/api/health` - должен вернуть статус backend

## 🔄 Шаг 9: Обновление приложения

Для обновления приложения до последней версии:

```bash
cd /opt/nardist

# Сохраняем изменения (если есть)
git stash

# Получаем последние изменения
git pull origin main

# Пересобираем и перезапускаем
docker compose -f docker-compose.prod.yml build --no-cache backend frontend
docker compose -f docker-compose.prod.yml up -d

# Применяем миграции (если есть новые)
docker compose -f docker-compose.prod.yml exec backend npx prisma migrate deploy
```

## 🛠️ Полезные команды

### Просмотр логов

```bash
# Все сервисы
docker compose -f docker-compose.prod.yml logs -f

# Конкретный сервис
docker compose -f docker-compose.prod.yml logs -f backend
```

### Остановка приложения

```bash
docker compose -f docker-compose.prod.yml down
```

### Запуск приложения

```bash
docker compose -f docker-compose.prod.yml up -d
```

### Перезапуск сервиса

```bash
docker compose -f docker-compose.prod.yml restart backend
```

### Вход в контейнер

```bash
# Backend
docker compose -f docker-compose.prod.yml exec backend sh

# PostgreSQL
docker compose -f docker-compose.prod.yml exec postgres psql -U nardist -d nardist_db
```

### Очистка неиспользуемых образов

```bash
docker system prune -a
```

### Просмотр использования ресурсов

```bash
docker stats
```

## 🗄️ Резервное копирование базы данных

### Создание бэкапа

```bash
cd /opt/nardist
source .env

docker compose -f docker-compose.prod.yml exec postgres pg_dump -U ${POSTGRES_USER} ${POSTGRES_DB} > backup_$(date +%Y%m%d_%H%M%S).sql
```

### Восстановление из бэкапа

```bash
cd /opt/nardist
source .env

cat backup_20241215_120000.sql | docker compose -f docker-compose.prod.yml exec -T postgres psql -U ${POSTGRES_USER} ${POSTGRES_DB}
```

## 🔧 Устранение неполадок

### Проблема: Контейнеры не запускаются

```bash
# Проверьте логи
docker compose -f docker-compose.prod.yml logs

# Проверьте статус
docker compose -f docker-compose.prod.yml ps

# Проверьте использование ресурсов
docker stats
```

### Проблема: База данных не подключается

```bash
# Проверьте, запущен ли PostgreSQL
docker compose -f docker-compose.prod.yml ps postgres

# Проверьте логи PostgreSQL
docker compose -f docker-compose.prod.yml logs postgres

# Проверьте подключение из backend контейнера
docker compose -f docker-compose.prod.yml exec backend sh
# В контейнере:
# npx prisma db pull
```

### Проблема: SSL сертификат не работает

```bash
# Проверьте, что DNS настроен
dig +short nardist.online

# Проверьте логи certbot
docker compose -f docker-compose.prod.yml logs certbot

# Проверьте конфигурацию Nginx
docker compose -f docker-compose.prod.yml exec nginx nginx -t
```

### Проблема: Frontend не открывается

```bash
# Проверьте логи frontend
docker compose -f docker-compose.prod.yml logs frontend

# Проверьте логи nginx
docker compose -f docker-compose.prod.yml logs nginx

# Проверьте, что frontend контейнер работает
docker compose -f docker-compose.prod.yml ps frontend
```

### Проблема: Backend возвращает ошибки

```bash
# Проверьте логи backend
docker compose -f docker-compose.prod.yml logs backend --tail=100

# Проверьте переменные окружения
docker compose -f docker-compose.prod.yml exec backend env | grep -E 'DATABASE_URL|REDIS_URL|JWT_SECRET'
```

## 📞 Поддержка

Если у вас возникли проблемы, проверьте:
1. Логи контейнеров
2. Настройки файрвола
3. DNS записи
4. Переменные окружения в `.env`

## 🎉 Готово!

После успешного развертывания ваше приложение будет доступно по адресу:
- **Frontend:** `https://nardist.online`
- **Backend API:** `https://nardist.online/api`

Удачи! 🚀

