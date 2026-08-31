#!/bin/bash

MESSAGE="$1"

if [ -z "$MESSAGE" ]; then
  echo "Usage: send-alert.sh <message>"
  exit 1
fi

if [ -n "$DISCORD_WEBHOOK_URL" ]; then
  python3 - "$MESSAGE" <<'EOF'
import json
import os
import sys
import urllib.request

message = sys.argv[1]
payload = {
    "content": "@everyone\n" + message,
    "allowed_mentions": {"parse": ["everyone"]},
}
data = json.dumps(payload).encode("utf-8")
request = urllib.request.Request(
    os.environ["DISCORD_WEBHOOK_URL"],
    data=data,
    headers={"Content-Type": "application/json"},
    method="POST",
)
urllib.request.urlopen(request)
EOF
  echo "Discord alert sent."
fi

if [ -n "$SLACK_WEBHOOK_URL" ]; then
  python3 - "$MESSAGE" <<'EOF'
import json
import os
import sys
import urllib.request

message = sys.argv[1]
payload = {"text": message}
data = json.dumps(payload).encode("utf-8")
request = urllib.request.Request(
    os.environ["SLACK_WEBHOOK_URL"],
    data=data,
    headers={"Content-Type": "application/json"},
    method="POST",
)
urllib.request.urlopen(request)
EOF
  echo "Slack alert sent."
fi
