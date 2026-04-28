#!/usr/bin/with-contenv bashio
set -e

NAME=$(bashio::config 'bluetooth_name')
MODE=$(bashio::config 'stream_mode')
URL=$(bashio::config 'stream_url')
PORT=$(bashio::config 'http_port')
BITRATE=$(bashio::config 'bitrate')

bashio::log.info "Starting Bluetooth Receiver V3"

# Runtime dirs
mkdir -p /run/dbus
mkdir -p /var/run/pulse
mkdir -p /tmp/pulse

# Bluetooth daemon
bluetoothd --experimental &
sleep 3

# PulseAudio system mode
pulseaudio --system \
  --disallow-exit \
  --daemonize=yes \
  --exit-idle-time=-1

sleep 5

# Load bluetooth modules
pactl load-module module-bluetooth-policy || true
pactl load-module module-bluetooth-discover || true

# Bluetooth pairing mode
bluetoothctl <<EOF
power on
agent on
default-agent
discoverable on
pairable on
system-alias $NAME
EOF

bashio::log.info "Bluetooth ready as: $NAME"

# Wait for BT audio source
sleep 8

if [ "$MODE" = "push" ] && [ -n "$URL" ]; then
    bashio::log.info "Pushing stream to $URL"

    exec ffmpeg \
      -f pulse -i default \
      -ac 2 -ar 44100 \
      -b:a ${BITRATE}k \
      -f mp3 "$URL"

else
    bashio::log.info "Serving stream at port $PORT"

    while true; do
      ffmpeg \
        -f pulse -i default \
        -ac 2 -ar 44100 \
        -b:a ${BITRATE}k \
        -content_type audio/mpeg \
        -f mp3 \
        -listen 1 \
        http://0.0.0.0:${PORT}/stream.mp3

      sleep 2
    done
fi
