# 🚀 Docker + Docker Compose Guide for Django + MySQL

This guide explains how to structure a multi-stage Dockerfile and orchestrate services with Docker Compose.  
It also clears up the infamous **`_mysql.so` confusion** (C extension + runtime libs).

---

## 🔹 How MySQL Python Binding Works

When you install `mysqlclient` via `pip`, Python needs a **C extension** to talk to the native MySQL libraries.

- **C Extension (`_mysql.so`)**
  - Built by `pip` at install time in Dev
  - Lives inside `site-packages/MySQLdb/`
  - Acts like a **translator** between Python and the C world

- **Runtime Library (`libmysqlclient.so.21`)**
  - Installed via `apt-get install libmysqlclient21` (OS-level package)
  - The C extension (`_mysql.so`) dynamically links against this at runtime

- **Dev Headers (`libmysqlclient-dev`)**
  - Only needed if no prebuilt wheel exists on PyPI
  - Required for compiling `_mysql.so` during build stage
  - Not needed in production

✅ **Key point:**  
- `_mysql.so` is created during `pip install mysqlclient` in Dev.  
- `libmysqlclient.so.21` must exist in Prod via `apt`.  
- Site-packages (Python deps) are **copied from Dev → Stage/Prod**.

---

## 🔹 Multi-Stage Dockerfile

```dockerfile
# ====================================
# ARTIFACTS AND BASE ARGS
ARG BASE_IMAGE=python
ARG PY_VERSION=3.12
ARG PY_BASE=slim
ARG TZ=Asia/Kolkata
ARG ZIP_NAME=Project_playground.zip
ARG ZIP_DIR=/updated_zip
ARG PROJ_NAME=project
# ===========================================================
# 1) DEV: full toolchain (compilers/headers) + pip cache
#    Code is expected to be MOUNTED in dev, not copied.
# ===========================================================
FROM ${BASE_IMAGE}:${PY_VERSION}-${PY_BASE} AS dev

ARG TZ=Asia/Kolkata
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    TZ=${TZ} \
    APP_HOME=/app \
    TMP=/tmp \
    SH_PATH=/usr/local/bin

WORKDIR ${APP_HOME}

RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    default-libmysqlclient-dev \
    pkg-config \
    unzip \
    tzdata \
    tree \
    && rm -rf /var/lib/apt/lists/*

COPY ./multistagebuild/requirements-dev-test.txt ./multistagebuild/requirements.txt ${TMP}/

RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --upgrade pip && \
    pip install -r ${TMP}/requirements-dev-test.txt && \
    pip install -r ${TMP}/requirements.txt

COPY ./bash_files/entrypoint.sh ${SH_PATH}/
RUN chmod +x ${SH_PATH}/entrypoint.sh

EXPOSE 8000
ENTRYPOINT ["sh", "-c", "${SH_PATH}/entrypoint.sh"]

# ===========================
# 2) TEST
# ===========================
FROM dev AS test-qa

COPY ./bash_files/qa.sh ${SH_PATH}/
RUN chmod +x ${SH_PATH}/qa.sh

ENTRYPOINT ["sh", "-c", "${SH_PATH}/qa.sh"]

# ===========================
# 3) STAGE (Pre-production with embedded code)
# ===========================
FROM ${BASE_IMAGE}:${PY_VERSION}-${PY_BASE} AS stage

ARG PY_VERSION=3.12
ARG TZ=Asia/Kolkata
ARG ZIP_NAME=Project_playground.zip
ARG ZIP_DIR=/updated_zip
ARG PROJ_NAME=project

LABEL org.opencontainers.image.title="lets_docker stage image" \
      org.opencontainers.image.description="Stage image with embedded project code" \
      org.opencontainers.image.source="https://github.com/zeroisinfinity/lets_docker"

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=${TZ} \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    APP_HOME=/app \
    ULLIB_PATH=/usr/local/lib \
    ULB_PATH=/usr/local/bin \
    SH_PATH=/usr/local/bin

RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update && apt-get install -y --no-install-recommends \
    default-libmysqlclient-dev \
    tzdata \
    curl \
    unzip \
    tree \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN addgroup --system proj_playground && \
    adduser --system --ingroup proj_playground proj

# Copy Python packages and binaries from dev
COPY --from=dev ${ULLIB_PATH}/python${PY_VERSION}/site-packages ${ULLIB_PATH}/python${PY_VERSION}/site-packages
COPY --from=dev ${ULB_PATH} ${ULB_PATH}

# Set working directory (creates /app if it doesn't exist)
WORKDIR ${APP_HOME}

# Copy and extract the ZIP file (embedded code)
COPY ${ZIP_DIR}/${ZIP_NAME} ./
RUN unzip ${ZIP_NAME} && \
    rm ${ZIP_NAME}

# Copy entrypoint
COPY bash_files/entrypoint.sh ${SH_PATH}/
RUN chmod +x ${SH_PATH}/entrypoint.sh

# Set ownership
RUN chown -R proj:proj_playground ${APP_HOME}

USER proj
WORKDIR ${APP_HOME}
EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

ENTRYPOINT ["sh", "-c", "${SH_PATH}/entrypoint.sh"]

# ===========================
# 4) PROD
# ===========================
FROM stage AS prod
USER proj
ENTRYPOINT ["sh", "-c", "${SH_PATH}/entrypoint.sh"]
```

``` mermaid
flowchart TD
    Dev[Dev Stage: Build tools + headers + pip install]
    Test[Test Stage: Run pytest]
    Stage[Stage: Runtime libs + site-packages copied from Dev]
    Prod[Prod: Same as Stage + Gunicorn Entrypoint]
    DB[(MySQL Container)]

    Dev --> Test
    Dev --> Stage
    Stage --> Prod
    Prod --> DB
    Dev --> DB
```
