#!/bin/bash
set -euo pipefail

# Validate required environment variables
: "${IMAGES:?❌ Please set the IMAGES environment variable (space-separated image list)}"
: "${CONTAINER_REGISTRY:=docker.io}"  # Default to docker.io
: "${CONTAINER_NAMESPACE:?❌ Please set the CONTAINER_NAMESPACE environment variable}"

# Split the IMAGES variable into an array
IFS=' ' read -r -a IMAGE_ARRAY <<< "$IMAGES"

# Loop through each image
for IMAGE in "${IMAGE_ARRAY[@]}"; do
  echo "🚀 Processing image: $IMAGE"

  IMAGE_NAME=$(echo "$IMAGE" | cut -d':' -f1)
  IMAGE_TAG=$(echo "$IMAGE" | cut -s -d':' -f2)
  [[ -z "$IMAGE_TAG" ]] && IMAGE_TAG="latest"

  FORM_IMAGE="${IMAGE_NAME}:${IMAGE_TAG}"

  if [[ "$IMAGE_TAG" == "latest" ]]; then
    TO_IMAGE="${CONTAINER_REGISTRY}/${CONTAINER_NAMESPACE}:${IMAGE_NAME##*/}"
  else
    TO_IMAGE="${CONTAINER_REGISTRY}/${CONTAINER_NAMESPACE}:${IMAGE_NAME##*/}-${IMAGE_TAG}"
  fi

  echo "📥 Pulling image: $FORM_IMAGE ..."
  docker pull "$FORM_IMAGE"

  echo "🏷️  Tagging image as: $TO_IMAGE ..."
  docker tag "$FORM_IMAGE" "$TO_IMAGE"

  echo "📤 Pushing image to remote registry ..."
  docker push "$TO_IMAGE"

  echo "🧹 Removing local images: $FORM_IMAGE and $TO_IMAGE ..."
  docker rmi -f "$FORM_IMAGE" "$TO_IMAGE" || true

  echo "✅ Successfully synced: $TO_IMAGE"
  echo "-----------------------------"
done

echo "🎉 All images have been successfully synced!"
