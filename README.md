# Medplum Devbox

A [Medplum](https://www.medplum.com/) docker image that you can use to run your local development againt it.

Differences with the current (as of 2022-12-17) [official medplum docker image](https://hub.docker.com/r/medplum/medplum-server):
 - Runs **BOTH** the server **AND** the front-end app concurrently, so that once it's started you can [connect to the app](http://localhost:3000) right away
 - Runs in development mode; this means a slower startup and execution time
 - Automatically seeds a `ClientApplication` with default, stable [credentials](#default-application) in addition to the [default medplum user](#default-user)
 - Multi-arch: `arm64` in addition to `amd64` to support running smoothly on Apple Silicon as well as X86


**DO NOT USE IN PRODUCTION**.

This image exists to support local development workflows easily. The fact that it has a default application configured
means that you should never use this in production.

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
      - ./medplum.config.json:/workspace/packages/server/medplum.config.json

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
      - ./postgres.conf:/usr/local/etc/postgres/postgres.conf
      - ./load_extensions.sql:/docker-entrypoint-initdb.d/load_extensions.sql

  redis:
    image: redis:6-bullseye
    command: redis-server --requirepass medplum
    ports:
      - '6379:6379'

volumes:
  postgres_data:
```

Example of content for the volume-mounted files can be found here:
 - [`medplum.config.json`](https://github.com/ensage-health/medplum-devbox/blob/main/medplum/medplum.config.json)
 - [`postgres.conf`](https://github.com/ensage-health/medplum-devbox/blob/main/postgres/postgres.conf)
 - [`load_extensions.sql`](https://github.com/ensage-health/medplum-devbox/blob/main/postgres/load_extensions.sql)

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

