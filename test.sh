#!/usr/bin/env bash

set -euo pipefail

SPRITE_NAME="dot"
CHECKPOINT_VERSION="v1"
REMOTE_DIR="/tmp/dotfiles"
ARCHIVE_PATH="$(mktemp -t dotfiles.XXXXXX).tar.gz"
SPRITE_API_URL="${SPRITES_API_URL:-https://api.sprites.dev}"

if [ -f ".env" ]; then
  set -a
  # shellcheck source=/dev/null
  . ".env"
  set +a
fi

if [ -z "${SPRITE_TOKEN:-}" ]; then
  echo "missing SPRITE_TOKEN (set in .env or env var)"
  exit 1
fi

cleanup() {
  rm -f "$ARCHIVE_PATH"
}
trap cleanup EXIT

echo "restoring checkpoint ${CHECKPOINT_VERSION} on sprite ${SPRITE_NAME}"
sprite -s "${SPRITE_NAME}" checkpoint restore "${CHECKPOINT_VERSION}"

echo "creating repo archive"
COPYFILE_DISABLE=1 tar -czf "$ARCHIVE_PATH" \
  --exclude ".git" \
  --exclude ".DS_Store" \
  -C "$(pwd)" .

echo "uploading archive via filesystem api"
curl -sS -X PUT \
  -H "Authorization: Bearer ${SPRITE_TOKEN}" \
  -H "Content-Type: application/octet-stream" \
  --data-binary @"${ARCHIVE_PATH}" \
  "${SPRITE_API_URL}/v1/sprites/${SPRITE_NAME}/fs/write?path=/tmp/dotfiles.tar.gz&mkdir=true" \
  > /dev/null

echo "extracting archive to ${REMOTE_DIR} via filesystem api read"
curl -sS -H "Authorization: Bearer ${SPRITE_TOKEN}" \
  "${SPRITE_API_URL}/v1/sprites/${SPRITE_NAME}/fs/read?path=/tmp/dotfiles.tar.gz" \
  | sprite -s "${SPRITE_NAME}" exec /bin/sh -c \
      "rm -rf '${REMOTE_DIR}' && mkdir -p '${REMOTE_DIR}' && tar -xzf - -C '${REMOTE_DIR}'"

echo "running chezmoi apply from ${REMOTE_DIR}"
sprite -s "${SPRITE_NAME}" exec /bin/sh -c "\
if [ -x /home/linuxbrew/.linuxbrew/bin/chezmoi ]; then \
  export PATH=/home/linuxbrew/.linuxbrew/bin:\$PATH; \
fi; \
command -v chezmoi >/dev/null 2>&1 || { echo 'chezmoi not found on sprite'; exit 127; }; \
chezmoi init --apply --source '${REMOTE_DIR}'"

echo "entering fish shell"
sprite -s "${SPRITE_NAME}" exec -tty /usr/bin/fish --login
