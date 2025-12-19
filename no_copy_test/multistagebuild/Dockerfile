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

RUN addgroup --system proj_playground && \
    adduser --system --ingroup proj_playground proj

COPY --from=dev ${ULLIB_PATH}/python${PY_VERSION}/site-packages ${ULLIB_PATH}/python${PY_VERSION}/site-packages
COPY --from=dev ${ULB_PATH} ${ULB_PATH}

WORKDIR ${APP_HOME}

COPY ${ZIP_DIR}/${ZIP_NAME} ./
RUN unzip ${ZIP_NAME} && \
    rm ${ZIP_NAME}

COPY bash_files/entrypoint.sh ${SH_PATH}/
RUN chmod +x ${SH_PATH}/entrypoint.sh

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
