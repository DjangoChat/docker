# syntax=docker/dockerfile:1.7

############################
# Development
############################
FROM node:22-alpine

ENV APP_HOME=/app

WORKDIR $APP_HOME

COPY frontend/package.json frontend/package-lock.json ./

RUN npm ci

COPY frontend/ ./

EXPOSE 5173

CMD ["npm", "run", "dev"]
