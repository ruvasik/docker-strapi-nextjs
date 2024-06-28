#!/bin/bash

# Stop on error
set -e

export $(grep -v '^#' .env | xargs)

# Initialize env variables
SH_MODE=false
YARN_MODE=false
SERVICE="${APP_NAME}-nextjs"

# Set default values for env variables
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

# First run build
initial_build() {
  echo "Running initial build..."

  envsubst < docker/nextjs/docker-compose.build.tpl.yml > docker/nextjs/docker-compose.build.yml

  docker-compose --env-file .env -f docker/nextjs/docker-compose.build.yml -f docker/docker-compose.networks.yml build
  docker-compose --env-file .env -f docker/nextjs/docker-compose.build.yml -f docker/docker-compose.networks.yml up -d

  container_id=$(docker-compose -f docker/nextjs/docker-compose.build.yml ps -q "${SERVICE}")
  echo "Container ID: $container_id"

  sleep 5

  # Copy to frontend folder
  echo "Copying files from container to host..."
  docker cp $container_id:/usr/app ./frontend
}

envsubst < docker/docker-compose.networks.tpl.yml > docker/docker-compose.networks.yml
envsubst < docker/nextjs/docker-compose.tpl.yml > docker/nextjs/docker-compose.yml

# Check /frontend, if not - run initial build
if [ ! -d "./frontend" ]; then
  initial_build
fi

if [ -z "$arg" ]; then
  echo "FRONTEND: yarn dev mode"

  docker-compose --env-file .env -f docker/nextjs/docker-compose.yml -f docker/docker-compose.networks.yml up -d
  docker-compose --env-file .env -f docker/nextjs/docker-compose.yml -f docker/docker-compose.networks.yml logs
elif [ "$SH_MODE" = true ]; then
  echo "FRONTEND: sh mode";

  docker-compose --env-file .env -f docker/nextjs/docker-compose.yml -f docker/docker-compose.networks.yml up -d
  docker-compose --env-file .env -f docker/nextjs/docker-compose.yml -f docker/docker-compose.networks.yml exec "${SERVICE}" /bin/sh
else
  echo "FRONTEND: yarn mode with arg: $arg";

  docker-compose --env-file .env -f docker/nextjs/docker-compose.yml -f docker/docker-compose.networks.yml up -d
  docker-compose --env-file .env -f docker/nextjs/docker-compose.yml -f docker/docker-compose.networks.yml exec "${SERVICE}" /bin/sh /bin/sh -c "yarn $arg"
fi
