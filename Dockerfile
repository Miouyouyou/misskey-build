FROM node:14.0.0-alpine AS base

ENV NODE_ENV=production

RUN npm i -g npm@latest

WORKDIR /misskey

FROM base AS builder

RUN apk add --no-cache \
    autoconf \
    automake \
    file \
    g++ \
    gcc \
    libc-dev \
    libtool \
    make \
    nasm \
    pkgconfig \
    python \
    zlib-dev \
    git

RUN git clone --depth 1 https://github.com/syuilo/misskey
RUN cd misskey && yarn install
RUN cd misskey && yarn build

FROM base AS runner

RUN apk add --no-cache \
    ffmpeg \
    tini
RUN npm i -g web-push
ENTRYPOINT ["/sbin/tini", "--"]

COPY --from=builder /misskey/misskey ./

CMD ["npm", "run", "migrateandstart"]
