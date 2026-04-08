# syntax=docker/dockerfile:1.7

############################
# Base Node image
############################
FROM node:22-alpine AS base

ENV APP_HOME=/app

WORKDIR $APP_HOME

COPY services/frontend/package.json services/frontend/package-lock.json ./

RUN npm ci

COPY services/frontend/ ./frontend

############################
# Build
############################
FROM base AS build

WORKDIR $APP_HOME/frontend

ENV VITE_API_URL=http://localhost:8000/api/v1

RUN npm run build


############################
# Development (nginx)
############################
FROM nginx:stable-alpine

COPY --from=build /app/frontend/dist /usr/share/nginx/html
COPY services/docker/react/development/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
