# Medplum Devbox

This repository contains artifacts to build a self-contained docker distribution of medplum with the intention to run
it in **development** only.

It can then support local development against it.

**DO NOT USE IN PRODUCTION**.

## Ports

- `http://localhost:3000`: Medplum app
- `http://localhost:8103`: Medplum server
- `http://localhost:5432`: Postgresql server

## Credentials

### Default user:

- **Username**: admin@example.com
- **Password**: medplum_admin

### Default application:

- **Client ID**: f54370de-eaf3-4d81-a17e-24860f667912
- **Client Secret**: 75d8e7d06bf9283926c51d5f461295ccf0b69128e983b6ecdd5a9c07506895de

