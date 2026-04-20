#!/bin/bash
set -e

APP_DIR="/root/TweetOnRails"
IMAGE_NAME="tweeton-rails"
CONTAINER_NAME="tweeton-rails"
MASTER_KEY=$(cat "$APP_DIR/config/master.key")

cd "$APP_DIR"

echo ">>> Pulling latest code..."
git pull origin main

echo ">>> Building Docker image..."
docker build -t "$IMAGE_NAME" .

echo ">>> Stopping old container..."
docker stop "$CONTAINER_NAME" 2>/dev/null || true
docker rm "$CONTAINER_NAME" 2>/dev/null || true

echo ">>> Starting new container..."
docker run -d \
    --name "$CONTAINER_NAME" \
    -p 127.0.0.1:3000:3000 \
    -e RAILS_ENV=production \
    -e RAILS_MASTER_KEY="$MASTER_KEY" \
    -e RAILS_LOG_TO_STDOUT=true \
    -e RAILS_SERVE_STATIC_FILES=true \
    -v "$APP_DIR/storage:/rails/storage" \
    --restart always \
    "$IMAGE_NAME"

echo ">>> Reloading nginx..."
systemctl reload nginx

echo ">>> Cleaning up old images..."
docker image prune -f

echo ">>> Deployment finished successfully!"
