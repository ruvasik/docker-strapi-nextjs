# Используем официальный Node.js образ в качестве базового образа
FROM node:18-alpine AS builder

# Устанавливаем рабочую директорию внутри контейнера
WORKDIR /usr

RUN yarn create next-app app --ts --eslint --app --src-dir --use-yarn --no-tailwind --no-import-alias

# Устанавливаем рабочую директорию внутри контейнера
WORKDIR /usr/app

# Устанавливаем переменные окружения для Next.js
ENV NODE_ENV=development

EXPOSE 3000

# Указываем команду для запуска приложения
CMD ["yarn", "dev"]
