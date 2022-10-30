FROM node:16-alpine

WORKDIR /usr/src/legacy

COPY ./legacy/package.json ./legacy/package-lock.json ./
RUN npm ci
