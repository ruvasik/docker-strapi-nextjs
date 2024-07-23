#!/bin/bash

# Stop on error
set -e

export $(grep -v '^#' .env | xargs)

SH_MODE=false
BG_MODE=false
SERVICE="${APP_NAME}-nextjs"

# Установка значений переменных окружения
for arg in "$@"; do
  case $arg in
    --sh)
      SH_MODE=true
      ;;
    bg)
      BG_MODE=true
      ;;
    *)
      ARG="$arg"
      ;;
  esac
done

# Первичная сборка
initial_build() {
  echo "Running initial build..."
  envsubst < docker/nextjs/docker-compose.build.tpl.yml > docker/nextjs/docker-compose.build.yml
  docker-compose --env-file .env -f docker/nextjs/docker-compose.build.yml -f docker/docker-compose.networks.yml build
  docker-compose --env-file .env -f docker/nextjs/docker-compose.build.yml -f docker/docker-compose.networks.yml up -d

  container_id=$(docker-compose --env-file .env -f docker/nextjs/docker-compose.build.yml ps -q "${SERVICE}")
  echo "Container ID: $container_id"
  sleep 5
  echo "Copying files from container to host..."
  docker cp $container_id:/usr/app ./frontend
}

envsubst < docker/docker-compose.networks.tpl.yml > docker/docker-compose.networks.yml
envsubst < docker/nextjs/docker-compose.tpl.yml > docker/nextjs/docker-compose.yml

# Проверка и первичная сборка
if [ ! -d "./frontend" ]; then
  initial_build
fi

# Запуск контейнеров
echo "FRONTEND: Running with volume mounted..."
if [ "$BG_MODE" = true ]; then
  docker-compose --env-file .env -f docker/nextjs/docker-compose.yml -f docker/docker-compose.networks.yml up -d
  exit 0
else
  docker-compose --env-file .env -f docker/nextjs/docker-compose.yml -f docker/docker-compose.networks.yml up
  if [ "$SH_MODE" = true ]; then
    echo "FRONTEND: sh mode"
    docker-compose --env-file .env -f docker/nextjs/docker-compose.yml -f docker/docker-compose.networks.yml exec "${SERVICE}" /bin/sh
  elif [ -n "$ARG" ]; then
    echo "FRONTEND: yarn mode with arg: $ARG"
    docker-compose --env-file .env -f docker/nextjs/docker-compose.yml -f docker/docker-compose.networks.yml exec "${SERVICE}" /bin/sh -c "yarn $ARG"
  else
    echo "FRONTEND: yarn dev mode"
    docker-compose --env-file .env -f docker/nextjs/docker-compose.yml -f docker/docker-compose.networks.yml logs
  fi
fi
