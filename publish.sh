#!/bin/sh

echo "$HEX_USER\n$HEX_PASSWORD\n$LOCAL_PWD\n$LOCAL_PWD\n" | mix hex.user auth

echo "y\n$HEX_PASSWORD\n$LOCAL_PWD" | mix hex.publish
