FROM python:3.12.12-slim-bookworm

RUN apk update && apk add python3-dev gcc libc-dev
RUN pip install --upgrade pip

ARG ENV_TYPE=development

ENV APP_HOME=/app
ENV UV_COMPILE_BYTECODE=1
ENV UV_LINK_MODE=copy 
ENV ENV_TYPE=$ENV_TYPE
ENV UV_PYTHON_DOWNLOADS=never
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

WORKDIR $APP_HOME

ADD ./services/backend/src/requirements/base.txt $APP_HOME
ADD ./services/backend/src/requirements/${ENV_TYPE}.txt $APP_HOME
RUN pip install -r ${ENV_TYPE}.txt

ADD ./services/backend $APP_HOME/backend
ADD ./services/docker/django/server-entrypoint.sh $APP_HOME/backend/.