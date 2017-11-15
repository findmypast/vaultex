#!/bin/sh

echo "$HEX_USER\n$HEX_PASSWORD" | mix hex.user auth
echo "y\n$HEX_PASSWORD" | mix hex.publish
