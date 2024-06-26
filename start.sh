#!/bin/bash

# Остановить скрипт при ошибке
set -e

# Запуск start1.sh в фоне
./docker/strapi/start.sh &
PID1=$!

# Запуск start2.sh в фоне
./docker/nextjs/start.sh &
PID2=$!

# Ожидание завершения обоих процессов
wait $PID1
wait $PID2