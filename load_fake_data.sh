#!/bin/bash

set -e

ES_USER="elastic"
ES_PASS="xxxxxxxxxxxxxxx"
ES_HOST="https://localhost:9200"

echo "[+] Waiting for Elasticsearch to become ready..."
for i in {1..30}; do
    if curl -s -k -u $ES_USER:$ES_PASS $ES_HOST >/dev/null; then
        break
    fi
    sleep 1
done

echo "[+] Creating test index..."
curl -s -k -u $ES_USER:$ES_PASS -X PUT "$ES_HOST/test-index" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "number_of_shards": 1
  },
  "mappings": {
    "properties": {
      "title": { "type": "text" },
      "timestamp": { "type": "date" }
    }
  }
}
'

echo "[+] Generating and inserting 10,000 documents..."
rm -f bulk.json
for i in $(seq 1 10000); do
  echo '{"index":{"_index":"test-index"}}' >> bulk.json
  echo '{"title":"Document '$i'", "timestamp":"'"$(date -Iseconds)"'"}' >> bulk.json
done

curl -s -k -u $ES_USER:$ES_PASS -H "Content-Type: application/x-ndjson" -XPOST "$ES_HOST/_bulk?pretty" --data-binary @bulk.json
rm -f bulk.json

echo "[+] Verifying document count..."
curl -s -k -u $ES_USER:$ES_PASS "$ES_HOST/test-index/_count?pretty"
