#!/bin/bash

# Остановить скрипт при ошибке
set -e

# Функция для первичной сборки
initial_build() {
  echo "Running initial build..."
  docker-compose -f docker/strapi/docker-compose.build.yml build
  docker-compose -f docker/strapi/docker-compose.build.yml up -d

  container_id=$(docker-compose -f docker/strapi/docker-compose.build.yml ps -q strapi)
  echo "Container ID: $container_id"

  # Подождите немного, чтобы контейнер успел запуститься
  sleep 10

  # Копируйте файлы из контейнера в локальную директорию
  echo "Copying files from container to host..."
  docker cp $container_id:/usr/src/strapi ./backend

  # Остановите и удалите контейнеры после копирования
#  docker-compose -f docker/strapi/docker-compose.build.yml down
}

# Функция для запуска контейнера с монтированием
run_with_volume() {
  echo "Running with volume mounted..."
   docker-compose -f docker/strapi/docker-compose.yml up
}

# Проверьте, существует ли локальная директория /backend
if [ ! -d "./backend" ]; then
  initial_build
fi

# Запуск контейнера с монтированием
run_with_volume
