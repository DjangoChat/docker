# syntax=docker/dockerfile:1.7

############################
# Base Python image
############################
FROM python:3.12-slim-bookworm AS base

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    APP_HOME=/app

WORKDIR $APP_HOME

RUN pip install --upgrade pip


############################
# Builder (compile deps)
############################
FROM base AS builder

# Build-time system deps
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       gcc \
       python3-dev \
       libc-dev \
    && rm -rf /var/lib/apt/lists/*

ARG ENV_TYPE=production
ENV ENV_TYPE=${ENV_TYPE}

COPY services/backend/src/requirements/base.txt ./requirements/
COPY services/backend/src/requirements/${ENV_TYPE}.txt ./requirements/

RUN pip install wheel \
    && pip wheel --no-cache-dir \
       --wheel-dir /wheels \
       -r requirements/${ENV_TYPE}.txt


############################
# Runtime base (shared)
############################
FROM base AS runtime

# Runtime-only system deps
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       libc-dev \
    && rm -rf /var/lib/apt/lists/*

# Install dependencies from wheels
COPY --from=builder /wheels /wheels
RUN pip install --no-cache-dir /wheels/* \
    && rm -rf /wheels

# App code
COPY services/backend ./backend
COPY services/docker/django/server-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Security: non-root user
RUN useradd -m django
USER django

WORKDIR $APP_HOME/backend/src


############################
# Development target
############################
FROM runtime AS development

EXPOSE 8000

ENTRYPOINT ["/entrypoint.sh"]
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]


############################
# Production target
############################
FROM runtime AS production

EXPOSE 8000

ENTRYPOINT ["/entrypoint.sh"]
CMD ["gunicorn", "config.wsgi:application", \
     "--bind", "0.0.0.0:8000", \
     "--workers", "3", \
     "--threads", "2"]
