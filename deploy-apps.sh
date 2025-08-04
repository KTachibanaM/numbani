#!/usr/bin/env bash
set -e

# miniflux
cp /home/nixos/nixos/apps/miniflux/compose.yml /home/nixos/miniflux/compose.yml
docker compose -f /home/nixos/miniflux/compose.yml up -d

# rsshub
cp /home/nixos/nixos/apps/rsshub/compose.yml /home/nixos/rsshub/compose.yml
docker compose -f /home/nixos/rsshub/compose.yml up -d

# watchtower
mkdir -p /home/nixos/watchtower
cp /home/nixos/nixos/apps/watchtower/compose.yml /home/nixos/watchtower/compose.yml
docker compose -f /home/nixos/watchtower/compose.yml up -d
