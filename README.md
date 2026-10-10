# Goodlink

Goodlink is a small URL shortener built to make links readable and redirects measurable. Generated links use two familiar words and a random suffix; custom aliases and expiry are supported.

## Stack

- Go `net/http` API and redirect service.
- PostgreSQL for durable links, expiry, and click counts.
- Redis for the hot-link cache and atomic per-IP creation limits.
- Static HTML/CSS/JavaScript creator page; Docker Compose for local development.

## Run locally

Requirements: Docker Engine and the Docker Compose plugin.

1. Copy `.env.example` to `.env`.
2. Replace `ADMIN_TOKEN` with a random value of at least 24 characters.
3. Run `docker compose up --build`.
4. Open `http://localhost:8080`, enter the same token under **Creator access**, and create a link.

Useful endpoints: `GET /healthz`, `GET /metrics`, `POST /api/links`, and `GET /{slug}` for redirects. The creation API accepts `destination`, optional `custom_slug`, and `expiry_days` (`0`, `7`, `30`, or `90`), and requires `X-Admin-Token`.

## Design and limits

PostgreSQL is the source of truth. Redis caches successful slug lookups and applies an atomic rate limit. Cache failures fall back to PostgreSQL for redirects; creation fails closed if rate limiting is unavailable. Destination URLs must use HTTP or HTTPS; embedded credentials, local/single-label hosts, and private literal IPs are rejected. The service never fetches the destination URL.

This is a local MVP, not a production service: it has one shared admin token, no user accounts, ownership or self-service deletion; click counts are synchronous in PostgreSQL; metrics are process-local. Before public deployment, add user-level authorization, TLS, trusted proxy handling, backups, abuse reporting/takedown controls, and stronger operational monitoring. DNS names are not resolved because the service does not fetch URLs; the literal-IP check is not a DNS-rebinding defense for any future URL-fetching feature.

## Checks

Run `go test -race ./...` and `go vet ./...`. The business-rule tests use an in-memory store and do not replace integration tests against PostgreSQL and Redis. No production deployment or load-test results are claimed.
