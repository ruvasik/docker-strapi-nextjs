#!/bin/bash

# Остановить скрипт при ошибке
set -e

export $(grep -v '^#' .env | xargs)

BG_MODE=false

# Установка значений переменных окружения
for arg in "$@"; do
  case $arg in
    bg)
      BG_MODE=true
      ;;
    *)
      ;;
  esac
done

# Первичная сборка
initial_build() {
  echo "BACKEND: Running initial build..."
  envsubst < docker/strapi/docker-compose.build.tpl.yml > docker/strapi/docker-compose.build.yml
  docker-compose --env-file .env -f docker/strapi/docker-compose.build.yml -f docker/docker-compose.networks.yml build
  docker-compose --env-file .env -f docker/strapi/docker-compose.build.yml -f docker/docker-compose.networks.yml up -d

  container_id=$(docker-compose --env-file .env -f docker/strapi/docker-compose.build.yml ps -q "${SERVICE}")
  echo "BACKEND: Container ID: $container_id"
  sleep 10
  echo "BACKEND: Copying files from container to host..."
  docker cp $container_id:/usr/src/strapi ./backend
}

envsubst < docker/docker-compose.networks.tpl.yml > docker/docker-compose.networks.yml
envsubst < docker/strapi/docker-compose.tpl.yml > docker/strapi/docker-compose.yml

# Проверка и первичная сборка
if [ ! -d "./backend" ]; then
  initial_build
fi

# Запуск контейнеров
echo "BACKEND: Running with volume mounted..."
if [ "$BG_MODE" = true ]; then
  docker-compose --env-file .env -f docker/strapi/docker-compose.yml -f docker/docker-compose.networks.yml up -d
  exit 0
else
  docker-compose --env-file .env -f docker/strapi/docker-compose.yml -f docker/docker-compose.networks.yml up
fi
