#!/bin/bash

set -e

ES_USER="elastic"
ES_PASS="xxxxxxxxxxxxxx"
ES_HOST="https://localhost:9200"

echo "[+] Checking if test-index exists..."
if ! curl -s -k -u $ES_USER:$ES_PASS "$ES_HOST/test-index" | grep -q '"index"'; then
  echo "[!] test-index does not exist!"
  exit 1
fi

echo "[+] test-index found. Checking document count..."
RESPONSE=$(curl -s -k -u $ES_USER:$ES_PASS "$ES_HOST/test-index/_count")
COUNT=$(echo "$RESPONSE" | grep -o '"count":[0-9]*' | cut -d':' -f2)

if [[ "$COUNT" == "10000" ]]; then
  echo "[✔] test-index still contains 10,000 documents!"
else
  echo "[!] Unexpected count: $COUNT"
fi
