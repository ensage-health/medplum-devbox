#!/bin/sh
service postgresql start
service redis-server start
cd /workspace/packages/app && npm run dev &
cd /workspace/packages/server && npm run dev &

sleep 20

sudo -i -u postgres psql -f /workspace/create_default_app.sql

sleep infinity
