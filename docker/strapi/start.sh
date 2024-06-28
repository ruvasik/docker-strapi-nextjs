#!/bin/bash

# Остановить скрипт при ошибке
set -e

# Функция для первичной сборки
initial_build() {
  echo "BACKEND: Running initial build..."
  docker-compose --env-file .env -f docker/strapi/docker-compose.yml -f docker/docker-compose.networks.yml build
  docker-compose --env-file .env -f docker/strapi/docker-compose.yml -f docker/docker-compose.networks.yml up -d

  container_id=$(docker-compose --env-file .env -f docker/strapi/docker-compose.build.yml ps -q strapi)
  echo "BACKEND: Container ID: $container_id"

  # Подождите немного, чтобы контейнер успел запуститься
  sleep 10

  # Копируйте файлы из контейнера в локальную директорию
  echo "BACKEND: Copying files from container to host..."
  docker cp $container_id:/usr/src/strapi ./backend

  # Остановите и удалите контейнеры после копирования
#  docker-compose -f docker/strapi/docker-compose.build.yml down
}

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