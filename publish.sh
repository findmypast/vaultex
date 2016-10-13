#!/bin/sh

mkdir -p /root/.hex && echo "$HEX_USER\n$HEX_API_KEY" > /root/.hex/hex.config && echo "$HEX_PASSWORD\ny" | mix hex.publish
