#!/bin/bash

# Stop on error
set -e


if [ "$@" = "stop" ]; then
  docker-compose -f docker/nextjs/docker-compose.build.yml stop
  docker-compose -f docker/strapi/docker-compose.build.yml stop

  exit 0
fi


# Run strapi in background
echo "Backend strapi start..."
./docker/strapi/start.sh &
PID1=$!

# Run NextJS in background
echo "Frontend nextjs start..."
./docker/nextjs/start.sh &
PID2=$!

# Wait for strapi and nextjs to finish
wait $PID1
wait $PID2