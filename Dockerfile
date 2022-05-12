ARG FIVEM_NUM=5562
ARG FIVEM_VER=5562-25984c7003de26d4a222e897a782bb1f22bebedd
ARG DATA_VER=44fc68d7ee1b94ad67a211a6ff8234ce4ff760c8

# Credit to Spritsail <https://github.com/spritsail> for the original image

FROM alpine as builder

ARG FIVEM_VER
ARG DATA_VER

WORKDIR /output

RUN wget -O- http://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/${FIVEM_VER}/fx.tar.xz \
        | tar xJ --strip-components=1 \
            --exclude alpine/dev --exclude alpine/proc --exclude alpine/run --exclude alpine/sys \
    && mkdir -p /output/opt/cfx-server-data /output/usr/local/share \
    && wget -O- http://github.com/citizenfx/cfx-server-data/archive/${DATA_VER}.tar.gz \
        | tar xz --strip-components=1 -C opt/cfx-server-data \
    && apk -p $PWD add tini

ADD server.cfg opt/cfx-server-data
ADD entrypoint usr/bin/entrypoint

RUN chmod +x /output/usr/bin/entrypoint

#================

FROM scratch

ARG FIVEM_VER
ARG FIVEM_NUM
ARG DATA_VER

LABEL maintainer="ntr001 <https://github.com/ntr001>" \
        org.label-schema.name="FiveM" \
        org.label-schema.url="https://fivem.net" \
        org.label-schema.description="FiveM is a modification for Grand Theft Auto V enabling you to play multiplayer on customized dedicated servers." \
        org.label-schema.version=${FIVEM_NUM} \
        org.label-schema.version.fivem.binary=${FIVEM_VER} \
        org.label-schema.version.fivem.data=${DATA_VER}

COPY --from=builder /output/ /

WORKDIR /config
EXPOSE 30120
EXPOSE 30120/udp
EXPOSE 40120

# Default to an empty CMD, so we can use it to add seperate args to the binary
CMD [""]

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/entrypoint"]
