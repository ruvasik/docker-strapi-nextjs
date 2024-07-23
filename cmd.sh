#!/bin/bash

# Остановить выполнение при ошибке
set -e

# Загрузить переменные окружения
export $(grep -v '^#' .env | xargs)

# Проверить наличие переменной APP_NAME
if [ -z "$APP_NAME" ]; then
  echo "Ошибка: Переменная APP_NAME не задана."
  exit 1
fi

# Обработка сигнала прерывания
handle_signal() {
  echo "Получен сигнал прерывания, завершаем процессы..."
  docker-compose -f docker/strapi/docker-compose.yml -f docker/docker-compose.networks.yml stop
  docker-compose -f docker/nextjs/docker-compose.yml -f docker/docker-compose.networks.yml stop
  exit 0
}

# Ловушка для сигналов
trap 'handle_signal' SIGINT SIGTERM

if [ "$1" = "stop" ]; then
  docker-compose -f docker/strapi/docker-compose.yml -f docker/docker-compose.networks.yml stop
  docker-compose -f docker/nextjs/docker-compose.yml -f docker/docker-compose.networks.yml stop
  exit 0
elif [ "$1" = "down" ]; then
  docker-compose -f docker/strapi/docker-compose.yml -f docker/docker-compose.networks.yml down
  docker-compose -f docker/nextjs/docker-compose.yml -f docker/docker-compose.networks.yml down
  exit 0
fi

# Запуск Strapi
echo "Запуск backend..."
if [ "$1" = "bg" ]; then
  ./docker/strapi/cmd.sh bg &
else
  ./docker/strapi/cmd.sh &
fi
PID1=$!
echo "PID Strapi: $PID1"

# Запуск NextJS
echo "Запуск frontend..."
if [ "$1" = "bg" ]; then
  ./docker/nextjs/cmd.sh bg &
else
  ./docker/nextjs/cmd.sh &
fi
PID2=$!
echo "PID NextJS: $PID2"

if [ "$1" != "bg" ]; then
  # Ожидание завершения процессов
  wait $PID1
  wait $PID2
  handle_signal
fi
