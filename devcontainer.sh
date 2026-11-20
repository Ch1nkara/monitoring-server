#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
DOCKER_HOST="${DOCKER_HOST:-unix://${XDG_RUNTIME_DIR:-/run/user/${UID}}/podman/podman.sock}"
ID_LABEL='monitoring-server=monitoring-server'

case "${1:-up}" in
up)
  DOCKER_HOST="$DOCKER_HOST" devcontainer up --id-label "$ID_LABEL" --workspace-folder "$SCRIPT_DIR"
  DOCKER_HOST="$DOCKER_HOST" devcontainer exec --id-label "$ID_LABEL" --workspace-folder "$SCRIPT_DIR" bash
  ;;
down | stop)
  container_ids="$(DOCKER_HOST="$DOCKER_HOST" docker ps -q --filter "label=$ID_LABEL")"
  if [ -n "$container_ids" ]; then
    DOCKER_HOST="$DOCKER_HOST" docker kill $container_ids
  fi
  ;;
*)
  printf 'Usage: %s [up|down]\n' "${0##*/}" >&2
  exit 2
  ;;
esac
