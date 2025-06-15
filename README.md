# Docker Image Sync Action

A GitHub Action to synchronize multiple Docker images to a target container registry with customizable tagging support.

------

## Features

- Pull images from any public registry.
- Retag images for your target registry and namespace.
- Push images to your private or public registry.
- Supports multiple images with tags, e.g. `nginx:1.25 redis alpine:3.19`.
- Clean up local images after push to save disk space.

## Usage

### Example workflow

~~~
name: Sync Docker Images

on:
  workflow_dispatch:

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - name: Login to DockerHub
        uses: docker/login-action@v2
        with:
          registry: registry.cn-hangzhou.aliyuncs.com
          username: ${{ secrets.ACR_USERNAME }}
          password: ${{ secrets.ACR_PASSWORD }}

      - name: Sync Docker Images
        uses: chihqiang/image-sync-action@main
        with:
          registry: registry.cn-hangzhou.aliyuncs.com
          namespace: namespace
          images: |
            nginx:1.25
            redis
            alpine:3.19
~~~

## Inputs

| Name        | Required | Default     | Description                                                  |
| ----------- | -------- | ----------- | ------------------------------------------------------------ |
| `images`    | yes      | —           | Space-separated list of images to sync. Example: `"nginx:1.25 redis alpine:3.19"` |
| `registry`  | no       | `docker.io` | Target container registry URL, e.g. `docker.io` or `ghcr.io` |
| `namespace` | yes      | —           | Target namespace or repository (e.g., Docker Hub username or organization) |

## Notes

- This action assumes you have already logged in to your target container registry before running it.
- Use GitHub Secrets to safely store and inject your registry credentials.
- Images tagged with `latest` will be retagged with only the image name, others will append the tag with a hyphen.
   Example:
   `nginx:latest` → `registry.cn-hangzhou.aliyuncs.com/namespace:nginx`
   `nginx:1.25` → `registry.cn-hangzhou.aliyuncs.com/namespace:nginx-1.25`
