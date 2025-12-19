# Используем образ с предустановленными зависимостями
FROM nardist-frontend-deps:latest AS builder

WORKDIR /app

COPY . .
RUN npm run build

FROM nginx:latest

COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
