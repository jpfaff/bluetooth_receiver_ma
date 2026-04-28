ARG BUILD_FROM
FROM ${BUILD_FROM}

RUN apk add --no-cache \
    bash \
    bluez \
    bluez-deprecated \
    dbus \
    pulseaudio \
    pulseaudio-utils \
    pulseaudio-bluez \
    ffmpeg

COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
