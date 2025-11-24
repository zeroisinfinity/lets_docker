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
# syntax=docker/dockerfile:1.7

# =====================
# 1. Dev Stage
# =====================
FROM python:3.12-slim AS dev
WORKDIR /app
RUN apt-get update && apt-get install -y \
    build-essential \
    default-libmysqlclient-dev \
    pkg-config \
    curl git vim
COPY requirements.txt requirements-dev.txt ./
RUN pip install --upgrade pip && \
    pip install -r requirements.txt && \
    pip install -r requirements-dev.txt
COPY . .

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]

# =====================
# 2. Test Stage
# =====================
FROM dev AS test
CMD ["pytest", "-q"]

# =====================
# 3. Stage (Prod-like)
# =====================
FROM python:3.12-slim AS stage
WORKDIR /app
RUN apt-get update && apt-get install -y \
    default-libmysqlclient-dev \
    tzdata curl
# copy site-packages and Python binaries from Dev
COPY --from=dev /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=dev /usr/local/bin /usr/local/bin
COPY . .
CMD ["python", "manage.py", "check"]

# =====================
# 4. Prod Stage
# =====================
FROM stage AS prod
ENTRYPOINT ["gunicorn", "--bind", "0.0.0.0:8000", "project_playground.wsgi:application"]
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
