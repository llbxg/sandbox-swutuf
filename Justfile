THISDIR := justfile_directory()
SOURCE_DIR_HOST := THISDIR + '/isar-cip-core'

set dotenv-load := true
SW_VERSION := env('SW_VERSION', '1.0.0')
BUILD_DIR := env('BUILD_DIR', THISDIR + '/build')
HOST_IP := env('HOST_IP', '')

ARTIFACTS_URL := if HOST_IP != '' { 'http://' + HOST_IP + ':8011/artifacts' } else { '' }
METADATA_URL := if HOST_IP != '' { 'http://' + HOST_IP + ':8011/metadata' } else { '' }

guard-host-ip:
  if [ -z "{{HOST_IP}}" ]; then \
    echo "ERROR: HOST_IP is not set. Put HOST_IP in .env or export HOST_IP=..."; \
    exit 1; \
  fi

# ---- top-level commands ----
image cmd:
  @just "image-{{cmd}}"

server cmd:
  @just "server-{{cmd}}"

# ---- image commands ----
image-build: config
  KAS_BUILD_DIR="{{BUILD_DIR}}" \
  {{SOURCE_DIR_HOST}}/kas-container -l debug build

image-run: config
  if [ ! -f "{{THISDIR}}/start-qemu.sh" ]; then \
    cp "{{SOURCE_DIR_HOST}}/start-qemu.sh" "{{THISDIR}}/"; \
    chmod +x {{THISDIR}}/start-qemu.sh ; \
  fi;
  DISTRO_RELEASE=bookworm SWUPDATE_BOOT=true {{THISDIR}}/start-qemu.sh x86 -nographic

config: guard-host-ip
  SOURCE_DIR="/repo" \
  SOURCE_DIR_HOST="{{SOURCE_DIR_HOST}}" \
  SW_VERSION="{{SW_VERSION}}" \
  ARTIFACTS_URL="{{ARTIFACTS_URL}}" \
  METADATA_URL="{{METADATA_URL}}" \
  envsubst < config.yaml.tmpl > .config.yaml

# ---- server commands ----
server-setup: docker-setup rstuf-setup

server-clean: docker-cleanup

docker-setup:
  docker compose up -d

docker-cleanup:
  docker compose down -v

rstuf-setup:
  for i in $(seq 1 30); do \
    if curl -sf http://localhost:8008/api/v1/bootstrap/ > /dev/null; then \
      break; \
    fi; \
    sleep 1; \
  done; \
  curl -X POST "http://localhost:8008/api/v1/bootstrap/" \
    -H "Content-Type: application/json" \
    -d @settings/ceremony-payload.json

# ---- demo commands ----
upload-v2:
  if [ -d "{{THISDIR}}/build2" ]; then \
    {{THISDIR}}/tools/upload.sh {{THISDIR}}/build2/tmp/deploy/images/qemu-amd64/cip-core-image-cip-core-bookworm-qemu-amd64.swu; \
  fi;
