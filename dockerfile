#Etapa 1: AMBIENTE
FROM eclipse-temurin:21-jre-alpine

# ── Working directory ────────────────────────────────────────
WORKDIR /app

# ── Install only necessary tools (curl for healthcheck) ──────
RUN apk add --no-cache curl

# ── Directory structure ──────────────────────────────────────
RUN mkdir -p \
    /app/conf \
    /app/content \
    /app/logs \
    /app/security \
    /app/security/keygen \
    /app/security/ssl

# ── Copy config files and directory structure ────────────────

COPY src/main/resources/conf/gear-config.yml /app/conf/
COPY src/main/resources/conf/gear-http.yml /app/conf/
COPY src/main/resources/conf/gear-security.yml /app/conf/
COPY src/main/resources/conf/gear-server.yml /app/conf/
COPY src/main/resources/conf/gear-service.yml /app/conf/
COPY src/main/resources/conf/secrets.yml /app/conf/
COPY src/main/resources/conf/database.xml /app/conf/
COPY src/main/resources/security/ssl/.apiseries.p12 /app/security/
COPY src/main/resources/security/keygen/*_3DES_PUB.pem /app/security/keygen/
COPY src/main/resources/security/keygen/*_ASIMETRIC_PRI.pem /app/security/keygen/
COPY src/main/resources/security/keygen/*_ASIMETRIC_PUB.pem /app/security/keygen/
COPY src/main/resources/security/keygen/jwt.pem /app/security/keygen/
COPY src/main/resources/log4j2.xml /app/
COPY gear.sh /app/

# ── Copy application JAR from builder ───────────────────────
COPY ./target/apiseries-api.jar /app/

# ============================================================
# Environment Variables
# ============================================================
# ── Application ──────────────────────────────────────────────
ENV APINAME=channel-credentials
ENV NS_API=api.apiseries.com
ENV APP_PORT="8001"
ENV ENVIRONMENT=dev

# ── Application config paths ─────────────────────────────────
ENV GEAR_SERVER=/app/conf/gear-server.yml
ENV GEAR_SECURITY=/app/conf/gear-security.yml
ENV GEAR_SERVICE=/app/conf/gear-service.yml
ENV GEAR_CONFIG=/app/conf/gear-config.yml
ENV GEAR_HTTP=/app/conf/gear-http.yml
ENV GEAR_SECRETS=/app/conf/secrets.yml
ENV GEAR_DB=/app/conf/database.xml

# ============================================================
# JVM Parameters  (Java 21 - Virtual Threads ready)
# ============================================================
ENV JAVA_OPTS="\
    -server \
    -Dgear-server=${GEAR_SERVER} \
    -Dgear-security=${GEAR_SECURITY} \
    -Dgear-service=${GEAR_SERVICE} \
    -Dgear-http=${GEAR_HTTP} \
    -Dgear-config=${GEAR_CONFIG} \
    -Dgear-db=${GEAR_DB} \
    -Dgear-secrets=${GEAR_SECRETS}"

# ============================================================
# Ports
# ============================================================
EXPOSE ${APP_PORT}

# ============================================================
# Health check (using curl instead of wget for Alpine)
# ============================================================
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -sf http://${NS_API}/apis/nodes/${APINAME}/healthcheck/health \
        | grep -q '"status":"UP"' || exit 1

# ============================================================
# Runtime user & entrypoint
# ============================================================
ENTRYPOINT ["sh", "-c", "exec java $JAVA_OPTS -jar /app/apiseries-api.jar"]
