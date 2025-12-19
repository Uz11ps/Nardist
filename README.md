# Nardist - Telegram Mini App для игры в нарды

Telegram Mini App для игры в нарды с экономической системой, кланами, турнирами и другими функциями.

## Технологии

- **Frontend**: React, TypeScript, Vite, Telegram Web Apps SDK
- **Backend**: NestJS, TypeScript, Prisma, PostgreSQL, Redis
- **Infrastructure**: Docker, Docker Compose, Nginx
- **CI/CD**: GitHub Actions

## Быстрый старт

### Локальная разработка

1. Клонируйте репозиторий:
```bash
git clone https://github.com/Uz11ps/Nardist.git
cd Nardist
```

2. Запустите сервисы через Docker Compose:
```bash
docker-compose up -d
```

3. Примените миграции базы данных:
```bash
docker-compose exec backend npx prisma migrate dev
```

4. Откройте приложение:
- Frontend: http://localhost:5173
- Backend API: http://localhost:3000

### Production развертывание

**📖 Полное руководство по развертыванию:** [DEPLOY.md](./DEPLOY.md)

Это подробное руководство поможет вам развернуть приложение на чистом сервере Ubuntu 22.04 с нуля.

**🌐 Production URL:** https://nardist.online

## Структура проекта

```
nardist/
├── backend/          # NestJS backend
├── frontend/         # React frontend
├── nginx/            # Nginx конфигурация
├── scripts/          # Скрипты для деплоя и управления
├── docker-compose.yml           # Development конфигурация
├── docker-compose.prod.yml      # Production конфигурация
└── .github/workflows/           # CI/CD workflows
```

## Основные функции

- 🎮 Игра в короткие и длинные нарды
- 🤖 Игра против бота
- 👥 Онлайн игра с другими игроками
- 🏆 Турниры и рейтинговая система
- 💰 Экономическая система с ресурсами
- 🏘️ Система города и предприятий
- 👔 Кланы и клановые функции
- 🎨 Система скинов и маркетплейс
- 📚 Академия с обучающими материалами
- 🎯 Система заданий (квестов)

## Переменные окружения

См. `.env.example` для списка необходимых переменных окружения.

## Обновление с Git

Для обновления проекта с последними изменениями из репозитория:

```bash
cd /opt/nardist

# Сохранить локальные изменения и обновить
git stash
git pull origin main
git stash pop

# Пересобрать и перезапустить
docker compose -f docker-compose.prod.yml build --no-cache backend frontend
docker compose -f docker-compose.prod.yml up -d

# Применить миграции (если есть новые)
docker compose -f docker-compose.prod.yml exec backend npx prisma migrate deploy
```

## Документация

- **[DEPLOY.md](./DEPLOY.md)** - Полное руководство по развертыванию на Ubuntu 22.04
- [backend/README.md](./backend/README.md) - Документация бэкенда
- [frontend/README.md](./frontend/README.md) - Документация фронтенда

## Лицензия

Проприетарная лицензия. Все права защищены.

