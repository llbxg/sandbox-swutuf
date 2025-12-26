#!/usr/bin/env bash
set -euo pipefail

# Usage: ./upload.sh /path/to/file.swu
# Env overrides:
#   UPLOAD_URL (default: http://localhost:8011)
#   API_URL    (default: http://localhost:8008)
#   ARTIFACTS_PATH (default: /artifacts)

UPLOAD_URL="${UPLOAD_URL:-http://localhost:8011}"
API_URL="${API_URL:-http://localhost:8008}"
ARTIFACTS_PATH="${ARTIFACTS_PATH:-/artifacts}"
FILENAME="cip-core-qemu-amd64_update.swu"

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 /path/to/file.swu" >&2
  exit 1
fi

SRC="$1"
if [[ ! -f "$SRC" ]]; then
  echo "Error: file not found: $SRC" >&2
  exit 1
fi

WORK_DIR="$(dirname "$SRC")"
OUT="${WORK_DIR}/${FILENAME}"
cp -f "$SRC" "$OUT"

HASH=$(b2sum --length 256 "$OUT" | awk '{print $1}')
echo "blake2b-256: $HASH"

SIZE=$(stat --format="%s" "$OUT")
echo "size: ${SIZE} bytes"

# Upload the binary
UPLOAD_ENDPOINT="${UPLOAD_URL}/upload?path=${ARTIFACTS_PATH}"
echo "Uploading to: ${UPLOAD_ENDPOINT}"
curl -f -sS -F "path=@${OUT};filename=${HASH}.${FILENAME}" "${UPLOAD_ENDPOINT}"
echo "Upload OK"

# Register the artifact
API_ENDPOINT="${API_URL}/api/v1/artifacts/"
echo "Registering artifact: ${API_ENDPOINT}"
curl -f -sS -X POST "${API_ENDPOINT}" \
  -H "Content-Type: application/json" \
  -d "{
    \"artifacts\": [
      {
        \"info\": {
          \"hashes\": {
            \"blake2b-256\": \"${HASH}\"
          },
          \"length\": ${SIZE}
        },
        \"path\": \"$(basename "$OUT")\"
      }
    ]
  }"
echo
echo "Artifact registered"
