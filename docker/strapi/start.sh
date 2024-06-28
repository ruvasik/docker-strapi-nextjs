#!/bin/bash

# Остановить скрипт при ошибке
set -e

export $(grep -v '^#' .env | xargs)

SERVICE="${APP_NAME}-strapi"

# Функция для первичной сборки
initial_build() {
  echo "BACKEND: Running initial build..."

  envsubst < docker/strapi/docker-compose.build.tpl.yml > docker/strapi/docker-compose.build.yml

  docker-compose --env-file .env -f docker/strapi/docker-compose.build.yml -f docker/docker-compose.networks.yml build
  docker-compose --env-file .env -f docker/strapi/docker-compose.build.yml -f docker/docker-compose.networks.yml up -d

  container_id=$(docker-compose --env-file .env -f docker/strapi/docker-compose.build.yml ps -q "${SERVICE}")
  echo "BACKEND: Container ID: $container_id"

  # Подождите немного, чтобы контейнер успел запуститься
  sleep 10

  # Копируйте файлы из контейнера в локальную директорию
  echo "BACKEND: Copying files from container to host..."
  docker cp $container_id:/usr/src/strapi ./backend

  # Остановите и удалите контейнеры после копирования
#  docker-compose -f docker/strapi/docker-compose.build.yml down
}

envsubst < docker/docker-compose.networks.tpl.yml > docker/docker-compose.networks.yml
envsubst < docker/strapi/docker-compose.tpl.yml > docker/strapi/docker-compose.yml

# Функция для запуска контейнера с монтированием
run_with_volume() {
  echo "BACKEND: Running with volume mounted..."
   docker-compose --env-file .env -f docker/strapi/docker-compose.yml -f docker/docker-compose.networks.yml up
}

# Проверьте, существует ли локальная директория /backend
if [ ! -d "./backend" ]; then
  initial_build
fi

# Запуск контейнера с монтированием
run_with_volume