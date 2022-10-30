FROM node:16-alpine

WORKDIR /usr/src/frontend

COPY ./frontend/package.json ./frontend/package-lock.json ./
RUN npm ci
