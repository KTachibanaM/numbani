#!/usr/bin/env bash
set -e

# miniflux
cp /home/nixos/nixos/apps/miniflux/compose.yml /home/nixos/miniflux/compose.yml
docker compose -f /home/nixos/miniflux/compose.yml up -d

# rsshub
cp /home/nixos/nixos/apps/rsshub/compose.yml /home/nixos/rsshub/compose.yml
docker compose -f /home/nixos/rsshub/compose.yml up -d

# weibo-rss
cp /home/nixos/nixos/apps/weibo-rss/compose.yml /home/nixos/weibo-rss/compose.yml
docker compose -f /home/nixos/weibo-rss/compose.yml up -d

# telegram-to-rss
cp /home/nixos/nixos/apps/telegram-to-rss/compose.yml /home/nixos/telegram-to-rss/compose.yml
docker compose -f /home/nixos/telegram-to-rss/compose.yml up -d
