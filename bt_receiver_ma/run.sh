#!/usr/bin/with-contenv bashio
set -e

NAME=$(bashio::config 'bluetooth_name')
MODE=$(bashio::config 'stream_mode')
URL=$(bashio::config 'stream_url')
PORT=$(bashio::config 'http_port')

bashio::log.info "Starting Bluetooth Receiver"

mkdir -p /run/dbus
dbus-daemon --system --fork

bluetoothd --experimental &
sleep 3

pipewire &
wireplumber &
sleep 5

bluetoothctl <<EOF
power on
agent on
default-agent
discoverable on
pairable on
system-alias $NAME
EOF

bashio::log.info "Bluetooth device visible as: $NAME"

if [ "$MODE" = "push" ] && [ -n "$URL" ]; then
    bashio::log.info "Pushing stream to $URL"
    exec ffmpeg -re -f pulse -i default \
      -ac 2 -ar 44100 \
      -f mp3 "$URL"
else
    bashio::log.info "Serving stream on port $PORT"
    while true; do
      ffmpeg -re -f pulse -i default \
        -ac 2 -ar 44100 \
        -codec:a libmp3lame -b:a 192k \
        -content_type audio/mpeg \
        -f mp3 -listen 1 http://0.0.0.0:${PORT}/stream.mp3
      sleep 2
    done
fi
