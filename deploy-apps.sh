#!/usr/bin/env bash
set -e

# miniflux
cp /home/nixos/numbani/apps/miniflux/compose.yml /home/nixos/miniflux/compose.yml
docker compose up -f /home/nixos/miniflux/compose.yml up -d
