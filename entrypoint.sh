#!/bin/sh

if test ! -e /data/sqlite3.db ; then
  goatcounter db create site \
    -db sqlite3+/data/sqlite3.db -createdb \
    -vhost "${GOAT_VHOST}" \
    -user.email "${GOAT_EMAIL}" \
    -user.password "${GOAT_PASSWORD}"
fi

unset GOAT_VHOST
unset GOAT_EMAIL
unset GOAT_SECRET

goatcounter serve -listen 0.0.0.0:9080 -tls proxy -db sqlite3+/data/sqlite3.db -automigrate -websocket
