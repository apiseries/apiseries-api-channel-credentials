
# 📄 Documentación Técnica: `gear.sh`

## 1. Descripción General
`gear.sh` es una herramienta de línea de comandos (CLI) desarrollada en **Bash** para gestionar el ciclo de vida, la seguridad, el 
despliegue y la configuración de la **Gear API**. 

Permite a los desarrolladores y administradores:
- Iniciar, detener y monitorear el servicio Java localmente.
- Gestionar contenedores **Docker**.
- Configurar variables de entorno críticas.
- Generar certificados **SSL** y claves de seguridad (JWT, 3DES, Hash).
- Interactuar con modelos de **IA** locales mediante Ollama.
- Navegar por la estructura del proyecto de forma interactiva.

## 2. Requisitos Previos
Para ejecutar este script correctamente, el sistema debe contar con las siguientes herramientas instaladas:

| Herramienta | Versión Sugerida | Propósito |
| :--- | :--- | :--- |
| **Bash** | 4.0+ | Intérprete del script. |
| **Java** | 21+ (Recomendado) | Ejecución del API (`apiseries-api.jar`). |
| **Docker** | Latest | Contenerización del servicio. |
| **Maven** | 3.6+ | Descarga de dependencias de seguridad (`gear-keygen`). |
| **Ollama** | Latest | Ejecución de modelos de IA locales. |
| **fzf** | Latest | Menús interactivos de selección. |
| **jq** | Latest | Procesamiento de respuestas JSON (healthcheck). |
| **bat** | Latest | Visualización de archivos en el navegador. |
| **mkcert** | Latest | Generación de certificados SSL locales confiables. |
| **sudo** | - | El script requiere privilegios de root para ciertas operaciones. |

## 3. Instalación y Permisos
1. Asegúrese de que el script tenga permisos de ejecución:
   ```bash
   chmod +x gear.sh
   ```
2. **Nota Importante:** El script verifica si se está ejecutando como **root** o con **sudo**. Se recomienda ejecutarlo con 
privilegios elevados:
   ```bash
   sudo ./gear.sh
   ```

## 4. Variables de Entorno
El script depende de un conjunto específico de variables de entorno para configurar la ruta de los archivos de configuración y la 
conexión a la base de datos.

### Variables Requeridas (`ALLOWED_VARS`)
| Variable | Descripción |
| :--- | :--- |
| `GEAR_SERVER` | Configuración del servidor. |
| `GEAR_SECURITY` | Ruta a archivos de seguridad. |
| `GEAR_SERVICE` | Configuración del servicio. |
| `GEAR_HTTP` | Configuración HTTP. |
| `GEAR_CONFIG` | Ruta a la configuración general. |
| `GEAR_DB` | Cadena de conexión a la base de datos. |
| `GEAR_SECRETS` | Ruta a los secretos. |
| `APINAME` | Nombre identificador de la API. |
| `ENVIRONMENT` | Entorno de ejecución (dev, prod, etc.). |

### Configuración de Variables
Puede configurar estas variables usando el propio script:
```bash
./gear.sh env
# Seleccionar opción 'setenv' en el menú interactivo
```
O manualmente exportándolas en su shell (`.bashrc` o `.zshrc`):
```bash
export GEAR_SERVER="src/main/resources/conf/gear-server.yml"
export ENVIRONMENT="dev"
# ... etc
```

## 5. Comandos Disponibles

El script acepta un argumento para ejecutar una acción específica. Si no se proporciona ningún argumento, se inicia un **Menú 
Interactivo (TUI)**.

### 🟢 Ciclo de Vida del Servicio (Localhost)
| Comando | Descripción |
| :--- | :--- |
| `./gear.sh start` | Inicia el servicio en segundo plano (`nohup`). Guarda el PID en `process.pid`. |
| `./gear.sh stop` | Detiene el servicio usando el PID guardado. |
| `./gear.sh status` | Verifica si el proceso está activo (UP/DOWN). |
| `./gear.sh run` | Inicia el servicio en modo interactivo (bloqueante, muestra logs en consola). |

### 🔵 Gestión de Docker
| Comando | Descripción |
| :--- | :--- |
| `./gear.sh docker` | Construye la imagen y levanta el contenedor (modifica el `dockerfile` automáticamente). |
| `./gear.sh docker-start` | Inicia un contenedor existente detenido. |
| `./gear.sh docker-stop` | Detiene un contenedor en ejecución. |
| `./gear.sh docker-log` | Muestra los logs en tiempo real (`docker logs -f`). |
| `./gear.sh docker-status` | Verifica el estado del contenedor (UP/DOWN). |
| `./gear.sh docker-inspect` | Muestra los detalles técnicos de la imagen Docker. |

### 🔐 Seguridad y SSL
| Comando | Descripción |
| :--- | :--- |
| `./gear.sh ssl` | Menú para gestionar certificados (Keytool, Mkcert, Ver Keystore). |
| `./gear.sh sec` | Menú de criptografía (Generar claves 3DES, Asimétricas, Hash SHA, HEX). |
| `./gear.sh env` | Gestiona las variables de entorno (`setenv`, `getenv`, `identify`). |

### 🩺 Salud y Diagnóstico
| Comando | Descripción |
| :--- | :--- |
| `./gear.sh health` | Realiza una petición al endpoint `/healthcheck/health` y valida la respuesta. |
| `./gear.sh help` | Muestra la lista de ayuda con los comandos disponibles. |

### 🤖 Inteligencia Artificial
| Comando | Descripción |
| :--- | :--- |
| `./gear.sh ai` | Inicia la consola de IA, lista modelos disponibles desde Ollama y permite ejecutar uno. |
| `./gear.sh ai-list` | *(Mencionado en ayuda, redirige a lógica de IA)*. |

### 🛠 Utilidades
| Comando               | Descripción 															  |
| :---                  | :---                                                                    |
| `./gear.sh` (sin args) | Inicia el menú principal interactivo con `fzf`. 						  |
| `./gear.sh scafold`     | *(Accesible desde menú)* Navegador de archivos y carpetas del proyecto. |

## 6. Ejemplos de Uso

### Iniciar el servicio en segundo plano

```bash
sudo ./gear.sh start
```

### Verificar el estado de salud de la API
```bash
./gear.sh health
```

### Generar un certificado SSL local
```bash
./gear.sh ssl
# Seleccionar 'keytool' o 'mkcert' en el menú
```

### Desplegar en Docker
```bash
# Asegúrese de tener la variable ENVIRONMENT configurada
export ENVIRONMENT=prod
sudo ./gear.sh docker
```

### Generar claves de seguridad (JWT/3DES)
```bash
./gear.sh sec
# Seleccionar opción 1 (3DES) o 2 (ASYMETRIC)
# Esto descargará el jar 'gear-keygen' vía Maven y lo ejecutará.
```

## 7. Estructura de Archivos y Configuración
El script busca archivos de configuración en las siguientes rutas relativas:

- `src/main/resources/conf/`: Contiene `.yml` de configuración (server, service, http, config).
- `src/main/resources/security/`: Contiene certificados (`.p12`, `.pem`) y claves JWT.
- `target/apiseries-api.jar`: El ejecutable Java que se lanza con los comandos `start`/`run`.
- `dockerfile`: Modificado dinámicamente por el script para inyectar variables de entorno antes del build.


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


## 8. Notas Importantes y Advertencias

1.  **Compatibilidad de `sed`:** El script utiliza `sed -E -i ''` (sintaxis de macOS/BSD). En sistemas **Linux**, podría ser 
necesario ajustar la línea en la función `docker` a `sed -E -i`.
2.  **Permisos de Root:** Varias funciones (Docker, instalación de certificados) requieren `sudo`. El script validará esto al 
inicio.
3.  **Archivo `process.pid`:** El comando `stop` depende de la existencia de este archivo. Si se elimina manualmente, el script no 
podrá detener el proceso gracefully.
4.  **Dependencia Maven:** La función `sec` requiere acceso a internet para descargar el artefacto `com.gear.keygen:gear-keygen` 
desde el repositorio Maven.
5.  **Puertos:** El puerto se lee dinámicamente desde `gear-server.yml`. Asegúrese de que esté disponible.

## 9. Solución de Problemas (Troubleshooting)

- **Error: "Java is not installed"**: Verifique que `java -version` responda correctamente y esté en el `PATH`.
- **Error: "docker not found"**: Asegúrese de que el servicio Docker esté corriendo y el usuario tenga permisos (o use `sudo`).
- **Error: "ENVIRONMENT no está configurada"**: Ejecute `./gear.sh env` y configure la variable `ENVIRONMENT`.
- **Menú no se muestra**: Verifique que tenga instalado `fzf`. Sin él, los menús interactivos fallarán.

---
**Autor:** Apiseries - GQUEZADA  
**Versión del Script:** 1.0 (Basado en análisis de código)