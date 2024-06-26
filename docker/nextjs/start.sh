#!/bin/bash

# Stop on error
set -e

# Initialize env variables
SH_MODE=false
YARN_MODE=false

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
  docker-compose -f docker/nextjs/docker-compose.build.yml build
  docker-compose -f docker/nextjs/docker-compose.build.yml up -d

  container_id=$(docker-compose -f docker/nextjs/docker-compose.build.yml ps -q next-app)
  echo "Container ID: $container_id"

  sleep 5

  # Copy to frontend folder
  echo "Copying files from container to host..."
  docker cp $container_id:/usr/app ./frontend
}

# Check /frontend, if not - run initial build
if [ ! -d "./frontend" ]; then
  initial_build
fi

if [ -z "$arg" ]; then
  echo "FRONTEND: yarn dev mode"

  docker-compose -f docker/nextjs/docker-compose.yml up -d
#  docker-compose -f docker/nextjs/docker-compose.yml exec next-app /bin/sh -c "yarn dev"
  docker-compose -f docker/nextjs/docker-compose.yml logs
elif [ "$SH_MODE" = true ]; then
  echo "FRONTEND: sh mode";

  docker-compose -f docker/nextjs/docker-compose.yml up -d
  docker-compose -f docker/nextjs/docker-compose.yml exec next-app /bin/sh
else
  echo "FRONTEND: yarn mode with arg: $arg";

  docker-compose -f docker/nextjs/docker-compose.yml up -d
  docker-compose -f docker/nextjs/docker-compose.yml exec next-app /bin/sh -c "yarn $arg"
fi
