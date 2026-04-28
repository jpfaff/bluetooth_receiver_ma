ARG BUILD_FROM
FROM ${BUILD_FROM}

RUN apk add --no-cache \
    bash \
    bluez \
    bluez-deprecated \
    dbus \
    pipewire \
    wireplumber \
    ffmpeg \
    pulseaudio-utils

COPY run.sh /run.sh
RUN chmod +x /run.sh
CMD ["/run.sh"]
