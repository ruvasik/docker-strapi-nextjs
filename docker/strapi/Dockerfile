# Используем официальный образ Node.js в качестве базового образа
FROM node:18-alpine AS builder

# Создаем временную рабочую директорию для сборки Strapi-приложения
WORKDIR /tmp

# Устанавливаем необходимые зависимости и создаем Strapi-приложение
RUN yarn create strapi-app strapi --dbclient sqlite --skip-cloud --ts

# Переходим к финальному образу
FROM node:18-alpine

# Установка rsync
RUN apk add --no-cache rsync

# Создаем рабочую директорию для приложения
WORKDIR /usr/src/strapi

# Копируем созданное Strapi-приложение из временного образа
COPY --from=builder /tmp/strapi .

# Открываем порт $PORT, который используется Strapi
ENV PORT=$PORT
EXPOSE $PORT

# Команда для запуска Strapi
CMD ["yarn", "develop"]
