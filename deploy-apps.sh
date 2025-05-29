#!/usr/bin/env bash
set -e

# miniflux
cp /home/nixos/numbani/apps/miniflux/compose.yml /home/nixos/miniflux/compose.yml
docker compose -f /home/nixos/miniflux/compose.yml up -d

# rsshub
cp /home/nixos/numbani/apps/rsshub/compose.yml /home/nixos/rsshub/compose.yml
docker compose -f /home/nixos/rsshub/compose.yml up -d
