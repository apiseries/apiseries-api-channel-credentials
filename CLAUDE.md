# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`apiseries-api-channel-credentials` is a Java microservice built on the internal **Gear API** framework (`com.apiseries.gear`). It exposes a single GET endpoint that retrieves client credentials from MongoDB, filtered by the service name defined in `gear-security.yml`. The service uses JWT validation, asymmetric/3DES encryption for transport security, and resolves all secrets via environment variables at runtime.

## Build & Run Commands

**Build (produces `target/apiseries-api.jar` via Maven Shade plugin):**
```bash
mvn clean package
```

**Run locally (foreground):**
```bash
./gear.sh run
```

**Run as background service:**
```bash
./gear.sh start     # starts with nohup, writes PID to process.pid
./gear.sh stop      # kills process from process.pid
./gear.sh status    # checks if process is alive
```

**Health check:**
```bash
./gear.sh health    # hits /apis/nodes/channel-credentials/healthcheck/health
```

**Docker build & run:**
```bash
docker build -t apiseries-api-channel-credentials .
docker run -e ENVIRONMENT=dev apiseries-api-channel-credentials
```

## Required Environment Variables

Before running, the following must be set (validated by `gear.sh env`):

| Variable | Points to |
| `GEAR_SERVER` | `src/main/resources/conf/gear-server.yml`

| `GEAR_SECURITY` | `src/main/resources/conf/gear-security.yml`

| `GEAR_SERVICE` | `src/main/resources/conf/gear-service.yml`

| `GEAR_HTTP` | `src/main/resources/conf/gear-http.yml`

| `GEAR_CONFIG` | `src/main/resources/conf/gear-config.yml`

| `GEAR_DB` | `src/main/resources/conf/database.xml`

| `GEAR_SECRETS` | `src/main/resources/conf/secrets.yml`

| `APINAME` | Derived from `gear-security.yml` if not set

| `ENVIRONMENT` | `dev` / `qa` / `production` — selects secret profile in `secrets.yml`

Use `./gear.sh env setenv` to interactively persist a variable to `~/.zshrc`/`~/.bashrc`.

## Architecture

### Gear Framework Boot

`Application.main()` simply delegates to `com.apiseries.gear.startup.Application.run()`. The Gear framework reads all config YAMLs via JVM system properties (`-Dgear-server=...`, etc.) and wires up the service using the `gear-service.yml` descriptor.

### Request Flow

```
HTTP GET → Gear framework → Controller.toEmit(RequestMapper)
                               ↓
                          Service.getListCredentials(securityName)
                               ↓
                          MongoDBAdapter (ManagerAdapter singleton)
                               ↓
                          Returns JSONArray → strips _id fields → JSON response
```

### Service Wiring (`gear-service.yml`)

The Gear framework instantiates `Controller` by class name and injects dependencies via setter methods declared in `gear-service.yml`:

- `addDB(YAMLReader)` ← `gearconfig` (MongoDB config from `gear-config.yml`)
- `addSecurity(YAMLReader)` ← `gearsecurity` (service name from `gear-security.yml`)

The endpoint name `channel-credentials` must match:
- `security.name` in `gear-security.yml`
- The MongoDB config key in `gear-config.yml` (`mongodb.channel-credentials`)
- The node name in `gear-service.yml`

### Security & Encryption

PEM keys live in `src/main/resources/security/keygen/`:
- `*_3DES_PUB.pem` — 3DES public key for transport encryption
- `*_ASIMETRIC_PRI.pem` / `*_ASIMETRIC_PUB.pem` — asymmetric keypair
- `jwt.pem` — JWT signing key shared across all microservices in the ecosystem

Gear loads keys by filename pattern (timestamp prefix). `gear.sh keygen` generates new keys. `gear.sh ecosystem` propagates `jwt.pem` to sibling `apiseries-api*` projects at `../`.

SSL keystore lives in `src/main/resources/security/ssl/.apiseries.p12`. Generate with `./gear.sh ssl keytool`.

### Configuration Secret Resolution

`secrets.yml` defines three profiles (`dev`, `qa`, `production`). Values reference environment variables for non-dev environments (e.g. `${QA_MONGODB_URL}`). The active profile is selected by the `ENVIRONMENT` variable at JVM startup via `${sys:${env:ENVIRONMENT}.mongodb.MONGODB_URL}` syntax.

### Nexus Repository

The project deploys to a local Nexus instance. Ensure `~/.m2/settings.xml` has credentials for the `nexus` server ID pointing to `http://localhost:8081/`.

## Key Files

| Path | Purpose |
|---|---|
| `src/main/java/.../controller/Controller.java` | Main request handler — implements `ControllerImplement` |
| `src/main/java/.../service/Service.java` | MongoDB access layer |
| `src/main/java/.../tools/Utils.java` | `removeOid()` strips MongoDB `_id` fields from responses |
| `src/main/resources/conf/gear-service.yml` | Endpoint definition, DI wiring, healthcheck config |
| `src/main/resources/conf/gear-config.yml` | MongoDB connection config (collection, query, filter) |
| `src/main/resources/conf/secrets.yml` | Multi-environment secrets (dev values inline, qa/prod via env vars) |
| `gear.sh` | Dev lifecycle, keygen, SSL, health, env management |
| `dockerfile` | Runtime image (`eclipse-temurin:21-jre-alpine`), sets all `GEAR_*` env vars |
| `k8s/` | Kubernetes Deployment, Service, and Ingress manifests |
