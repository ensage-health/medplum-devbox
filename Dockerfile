FROM node:16-bullseye
LABEL org.opencontainers.image.authors="dev@ensagehealth.com"

ARG MEDPLUM_BRANCH=main

# Install OS dependencies
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends sudo git redis-server postgresql postgresql-contrib postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Clone source code and build
RUN cd / && git clone --depth 1 --branch $MEDPLUM_BRANCH https://github.com/medplum/medplum.git workspace
WORKDIR /workspace
RUN npm ci
RUN npm run build

# Configure postgres
RUN echo "\nlisten_addresses = '*'" >> /etc/postgresql/13/main/postgresql.conf \
    && echo "host    all             all             0.0.0.0/0            trust" >> /etc/postgresql/13/main/pg_hba.conf

# Create postgesql database and user
RUN echo 'CREATE USER medplum WITH PASSWORD '"'medplum'"';\n\
CREATE DATABASE medplum;\n\
GRANT ALL PRIVILEGES ON DATABASE medplum TO medplum;\n\
\\c medplum;\n\
CREATE EXTENSION "uuid-ossp";\n\
' > /tmp/psql.sql \
    && service postgresql start \
    && sudo -i -u postgres psql -f /tmp/psql.sql \
    && rm -f /tmp/psql.sql

# Configure Redis
RUN echo '\nrequirepass medplum' >> /etc/redis/redis.conf

# Run database migrations
# RUN echo '#!/bin/sh\n\
# service postgresql start && service redis-server start && node /workspace/packages/server/dist/index.js &\n\
# last_pid=$!\n\
# sleep 20\n\
# kill -KILL $last_pid\n\
# ' > /tmp/migrate.sh \
#     && chmod +x /tmp/migrate.sh \
#     && /tmp/migrate.sh \
#     && rm -f /tmp/migrate.sh

# Entrypoint script
ADD create_default_app.sql entrypoint.sh /workspace/

# ENTRYPOINT ["/workspace/entrypoint.sh"]
