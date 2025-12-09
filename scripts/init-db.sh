#!/usr/bin/env bash
set -euo pipefail

# Lightweight helper to start Postgres and load schema.sql from repo root.
# Usage: from repo root: `scripts/init-db.sh`

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCHEMA_FILE="$REPO_ROOT/schema.sql"
SERVICE_NAME="${SERVICE_NAME:-pg}"
POSTGRES_IMAGE="${POSTGRES_IMAGE:-postgres:16}"
DB_USER="${DB_USER:-postgres}"
DB_NAME="${DB_NAME:-app}"

if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: docker is not installed or not in PATH. Install and start Docker Desktop."
  exit 1
fi

echo "Using repo root: $REPO_ROOT"

if [ ! -f "$SCHEMA_FILE" ]; then
  echo "ERROR: schema file not found at $SCHEMA_FILE"
  exit 1
fi

echo "Bringing up compose services..."
cd "$REPO_ROOT"
docker compose up -d

echo "Pulling image $POSTGRES_IMAGE (best-effort)..."
docker pull "$POSTGRES_IMAGE" || true

CID="$(docker compose ps -q "$SERVICE_NAME" || true)"
if [ -z "$CID" ]; then
  echo "ERROR: could not find running container for service '$SERVICE_NAME'."
  echo "Run 'docker compose ps' to inspect services."
  exit 1
fi

echo "Postgres container id: $CID"

echo "Waiting for Postgres to accept connections..."
until docker exec -i "$CID" pg_isready -U "$DB_USER" >/dev/null 2>&1; do
  echo -n '.'
  sleep 1
done
echo

echo "Loading schema from $SCHEMA_FILE into database '$DB_NAME'..."
docker exec -i "$CID" psql -U "$DB_USER" -d "$DB_NAME" -v ON_ERROR_STOP=1 -f - < "$SCHEMA_FILE"

echo "Schema loaded successfully."
echo "You can inspect tables with: docker exec -it $CID psql -U $DB_USER -d $DB_NAME -c '\\dt'"

exit 0
