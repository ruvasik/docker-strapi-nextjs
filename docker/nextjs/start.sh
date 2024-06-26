#!/bin/bash

# Остановить скрипт при ошибке
set -e

# Инициализация переменных
SH_MODE=false
YARN_MODE=false

# Проверка параметров
for arg in "$@"
do
  case $arg in
    --sh)
    SH_MODE=true
    shift
    ;;
    *)
    shift
    ;;
  esac
done

# Функция для первичной сборки
initial_build() {
  echo "Running initial build..."
  docker-compose -f docker/nextjs/docker-compose.build.yml build
  docker-compose -f docker/nextjs/docker-compose.build.yml up -d

  container_id=$(docker-compose -f docker/nextjs/docker-compose.build.yml ps -q next-app)
  echo "Container ID: $container_id"

  # Подождите немного, чтобы контейнер успел запуститься
  sleep 10

  # Копируйте файлы из контейнера в локальную директорию
  echo "Copying files from container to host..."
  docker cp $container_id:/usr/app ./frontend

  # Остановите и удалите контейнеры после копирования
#  docker-compose -f docker/nextjs/docker-compose.build.yml down
}

# Проверьте, существует ли локальная директория /frontend
if [ ! -d "./frontend" ]; then
  initial_build
fi

if [ -z "$arg" ]; then
  echo "yarn dev mode"
  # Запуск контейнера с монтированием
  docker-compose -f docker/nextjs/docker-compose.yml up -d
  docker-compose -f docker/nextjs/docker-compose.yml exec next-app /bin/sh -c "yarn dev"
elif [ "$SH_MODE" = true ]; then
  echo "sh mode";
  docker-compose -f docker/nextjs/docker-compose.yml up -d
  docker-compose -f docker/nextjs/docker-compose.yml exec next-app /bin/sh
else
  echo "yarn mode - $arg";
  docker-compose -f docker/nextjs/docker-compose.yml up -d
  docker-compose -f docker/nextjs/docker-compose.yml exec next-app /bin/sh -c "yarn $arg"
fi
