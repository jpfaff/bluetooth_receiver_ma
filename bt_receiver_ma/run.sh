#!/usr/bin/with-contenv bashio
set -e

NAME=$(bashio::config 'bluetooth_name')

bashio::log.info "Starting Bluetooth Receiver"

# Runtime dirs
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
chmod 700 $XDG_RUNTIME_DIR

mkdir -p /run/dbus

# DBus
dbus-daemon --system --fork

# Bluetooth
if command -v bluetoothd >/dev/null 2>&1; then
    bluetoothd --experimental &
else
    bashio::log.error "bluetoothd missing from image"
    exit 1
fi

sleep 3

# PipeWire
pipewire &
wireplumber &

sleep 5

# Bluetooth setup
bluetoothctl <<EOF
power on
agent on
default-agent
discoverable on
pairable on
system-alias $NAME
EOF

bashio::log.info "Bluetooth ready as $NAME"

# Keep alive
sleep infinity
