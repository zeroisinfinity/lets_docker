
# ====================================
# ARTIFACTS AND BASE ARGS
ARG BASE_IMAGE=python
ARG PY_VERSION=3.12
ARG PY_BASE=slim
ARG APP_HOME=/app
ARG TMP=/tmp
ARG SH_PATH=/usr/local/bin
ARG ZIP_NAME=Project_playground.zip
ARG ZIP_DIR=/updated_zip
ARG TZ=Asia/Kolkata
ARG ULLIB_PATH=/usr/local/lib
ARG ULB_PATH=/usr/local/bin
ARG PROJ_NAME=project
# ===========================================================
# 1) DEV: full toolchain (compilers/headers) + pip cache
#    Code is expected to be MOUNTED in dev, not copied.
# ===========================================================
FROM ${BASE_IMAGE}:${PY_VERSION}-${PY_BASE} AS dev

ENV DEBIAN_FRONTEND=noninteractive\
    PYTHONUNBUFFERED=1\
    PYHTONDONTWRITEBYTECODE=1 \
    TZ=${TZ}

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

COPY requirements-dev-test.txt requirements.txt ${TMP}/

RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --upgrade pip && \
    pip install -r ${TMP}/requirements-dev-test.txt && \
    pip install -r ${TMP}/requirements.txt

COPY ../bash_files/entrypoint.sh ${SH_PATH}/
RUN chmod +x ${SH_PATH}/entrypoint.sh

EXPOSE 8000
ENTRYPOINT ["${SH_PATH}/entrypoint.sh"]


# ===========================
# 2) TEST
# ===========================

FROM dev AS test-QA

COPY ../bash_files/qa.sh ${SH_PATH}/
RUN chmod +x ${SH_PATH}/qa.sh

ENTRYPOINT ["${SH_PATH}/qa.sh"]

# ===========================
# 3) STAGE
# ===========================


FROM ${BASE_IMAGE}:${PY_VERSION}-${PY_BASE} AS stage

LABEL org.opencontainers.image.title="lets_docker prod image" \
      org.opencontainers.image.description="Production image that embeds an updated ZIP artifact" \
      org.opencontainers.image.source="https://github.com/zeroisinfinity/lets_docker"

ENV DEBIAN_FRONTEND=noninteractive\
    TZ=${TZ}
    PYTHONUNBUFFERED=1 \
    PYHTONDONTWRITEBYTECODE=1

RUN --mount=type=cache.target=/var/cache/apt \
    apt-get update && apt-get install -y --no-install-recommends \
    default-libmysqlclient-dev \
    tzdata \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN addgroup --system proj_playground && \
    adduser --system --ingroup proj_playground proj

COPY --from=dev ${ULLIB_PATH}/${BASE_IMAGE}-${PY_VERSION}/site-packages ${ULLIB_PATH}/${BASE_IMAGE}-${PY_VERSION}/site-packages
COPY --from=dev ${ULB_PATH} ${ULB_PATH}

COPY ..${ZIP_DIR}/${ZIP_NAME} ${APP_HOME}/
COPY --from=dev ${APP_HOME}/${PROJ_NAME} ${APP_HOME}/${PROJ_NAME}

COPY --from=dev ${SH_PATH}/entrypoint.sh ${SH_PATH}/
COPY ../bash_files/entrypoint.sh ${SH_PATH}/
RUN chmod +x ${SH_PATH}/entrypoint.sh

RUN chown -R proj:proj_playground ${APP_HOME}
USER proj

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1
ENTRYPOINT ["${SH_PATH}/entrypoint.sh"]

# ===========================
# 4) PROD
# ===========================

FROM stage AS prod
USER proj
ENTRYPOINT ["${SH_PATH}/entrypoint.sh"]


