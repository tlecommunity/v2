FROM node:16-alpine

WORKDIR /usr/src/stubs

COPY ./stubs/package.json ./stubs/package-lock.json ./
RUN npm ci
