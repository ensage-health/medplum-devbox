# Medplum Devbox

This repository contains artifacts to build a self-contained docker distribution of medplum with the intention to run
it in **development** only.

It can then support local development against it.

**DO NOT USE IN PRODUCTION**.

## Get started

Create a `docker-compose.yml` file with the following content:

```yaml
services:

  medplum:
    image: ghcr.io/ensage-health/medplum-devbox:latest
    depends_on:
      - redis
      - postgres
    ports:
      - '3000:3000'
      - '8103:8103'
    volumes:
      - ./medplum/medplum.config.json:/workspace/packages/server/medplum.config.json

  postgres:
    image: postgres:12-bullseye
    command: postgres -c config_file=/usr/local/etc/postgres/postgres.conf
    environment:
      - POSTGRES_USER=medplum
      - POSTGRES_PASSWORD=medplum
    ports:
      - '5432:5432'
    volumes: 
      - postgres_data:/var/lib/postgresql/data
      - ./postgres/postgres.conf:/usr/local/etc/postgres/postgres.conf
      - ./postgres/load_extensions.sql:/docker-entrypoint-initdb.d/load_extensions.sql

  redis:
    image: redis:6-bullseye
    command: redis-server --requirepass medplum
    ports:
      - '6379:6379'

volumes:
  postgres_data:
```

Example of content for the volume-mounted files can be found in this repository.

What is important:
 - `medplum.config.json` needs to point to the docker-network host of `postgres` and `redis` respectively
 - `load_extensions.sql` should create the `uuid-ossp` extension, as outlined in the medplum repository

## Ports

- `http://localhost:3000`: Medplum app
- `http://localhost:8103`: Medplum server

## Credentials

### Default user:

- **Username**: admin@example.com
- **Password**: medplum_admin

### Default application:

- **Client ID**: f54370de-eaf3-4d81-a17e-24860f667912
- **Client Secret**: 75d8e7d06bf9283926c51d5f461295ccf0b69128e983b6ecdd5a9c07506895de

