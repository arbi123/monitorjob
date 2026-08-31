#!/bin/bash

MESSAGE="$1"

if [ -z "$MESSAGE" ]; then
  echo "Usage: send-alert.sh <message>"
  exit 1
fi

if [ -n "$DISCORD_WEBHOOK_URL" ]; then
  curl -s -H "Content-Type: application/json" \
    -d "{\"content\":\"${MESSAGE}\"}" \
    "$DISCORD_WEBHOOK_URL"
  echo "Discord alert sent."
fi

if [ -n "$SLACK_WEBHOOK_URL" ]; then
  curl -s -H "Content-Type: application/json" \
    -d "{\"text\":\"${MESSAGE}\"}" \
    "$SLACK_WEBHOOK_URL"
  echo "Slack alert sent."
fi
