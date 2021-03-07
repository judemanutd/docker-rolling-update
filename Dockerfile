ARG VERSION_NODE=14.16-alpine3.12

# BASE stage
FROM node:${VERSION_NODE} as base
LABEL maintainer="Jude Fernandes"
WORKDIR /usr/src/app
COPY package.json ./
COPY package-lock.json ./
RUN npm ci --production
CMD ["npm","start"]
