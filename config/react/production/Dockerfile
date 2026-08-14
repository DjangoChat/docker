# syntax=docker/dockerfile:1.7

############################
# Base Node image
############################
FROM node:22-alpine AS base

ENV APP_HOME=/app

WORKDIR $APP_HOME

COPY services/frontend/package.json services/frontend/package-lock.json* ./

RUN npm install

COPY services/frontend/ ./
COPY environment/.env.production ./.env.production


############################
# Build
############################
FROM base AS build

ARG VITE_API_URL
ENV VITE_API_URL=${VITE_API_URL}

RUN npm run build


############################
# Production (nginx)
############################
FROM nginx:stable-alpine

COPY --from=build /app/dist /usr/share/nginx/html
COPY services/docker/react/production/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
