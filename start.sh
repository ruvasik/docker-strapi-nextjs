#!/bin/bash

# Остановить выполнение при ошибке
set -e

# Загрузить переменные окружения из .env файла
export $(grep -v '^#' .env | xargs)

# Проверить, задана ли переменная APP_NAME
if [ -z "$APP_NAME" ]; then
  echo "Ошибка: Переменная APP_NAME не задана."
  exit 1
fi

# Установить имена сервисов
SERVICE_STRAPI="${APP_NAME}-strapi"
SERVICE_NEXTJS="${APP_NAME}-nextjs"

stop_container() {
  local container_name="$1"
  local container_id
  container_id=$(docker ps -qf "name=${container_name}")

  if [ -n "$container_id" ]; then
    echo "Остановка контейнера ${container_name}..."
    docker stop "$container_id" || echo "Не удалось остановить контейнер ${container_name}."
  else
    echo "Контейнер ${container_name} не найден."
  fi
}

remove_container() {
  local container_name="$1"
  local container_id
  container_id=$(docker ps -a -qf "name=${container_name}")

  if [ -n "$container_id" ]; then
    echo "Удаление контейнера ${container_name}..."
    docker rm "$container_id" || echo "Не удалось удалить контейнер ${container_name}."
  else
    echo "Контейнер ${container_name} не найден."
  fi
}

if [ "$1" = "stop" ]; then
  stop_container "$SERVICE_STRAPI"
  stop_container "$SERVICE_NEXTJS"
  exit 0
elif [ "$1" = "down" ]; then
  stop_container "$SERVICE_STRAPI"
  stop_container "$SERVICE_NEXTJS"
  remove_container "$SERVICE_STRAPI"
  remove_container "$SERVICE_NEXTJS"
  exit 0
fi

# Запуск Strapi в фоне
echo "Запуск backend ${SERVICE_STRAPI}..."
./docker/strapi/start.sh &
PID1=$!

# Запуск NextJS в фоне
echo "Запуск frontend ${SERVICE_NEXTJS}..."
./docker/nextjs/start.sh &
PID2=$!

# Ожидание завершения Strapi и NextJS
wait $PID1
wait $PID2
