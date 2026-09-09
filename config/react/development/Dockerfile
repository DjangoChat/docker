# syntax=docker/dockerfile:1.7

############################
# Development
############################
FROM node:22-alpine

ENV APP_HOME=/app

# WebSocket base URL for Chat/Notification consumers. Left empty by default
# so the frontend derives ws:// from VITE_API_URL at runtime
# (see src/constants/Endpoints.tsx). Override via compose environment if the
# backend WS endpoint ever diverges from the API host/scheme.
ENV VITE_WS_URL=""

WORKDIR $APP_HOME

COPY frontend/package.json frontend/package-lock.json ./

RUN npm ci

COPY frontend/ ./

EXPOSE 5173

CMD ["npm", "run", "dev"]
