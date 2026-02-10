# External Integrations

**Analysis Date:** [YYYY-MM-DD]

## APIs and External Services

**_[Category]_:**
- _[Service]_ - _[What it's used for]_
  - SDK/Client: `[package name]` in `[path]`
  - Auth: `[ENV_VAR_NAME]`

**_[Category]_:**
- _[Service]_ - _[What it's used for]_
  - SDK/Client: `[package name]` in `[path]`
  - Auth: `[ENV_VAR_NAME]`

## Data Storage

**Databases:**
- _[Type/Provider]_
  - Connection: `[ENV_VAR_NAME]`
  - Client: `[ORM/client package]` configured in `[path]`

**File Storage:**
- _[Service or "Local filesystem only"]_ - Configured in `[path]`

**Caching:**
- _[Service or "None"]_ - Configured in `[path]`

## Authentication

**Auth Provider:**
- _[Service or "Custom"]_
  - Implementation: `[approach]` in `[path]`
  - Configure auth settings in `[path]`

## Monitoring

**Error Tracking:**
- _[Service or "None"]_ - Configured in `[path]`

**Logs:**
- _[Approach]_ - See `[path]`

## Deployment

**Hosting:**
- _[Platform]_ - Configuration in `[path]`

**CI Pipeline:**
- _[Service or "None"]_ - Configuration in `[path]`

## Environment Configuration

**Required env vars:**

Use the following environment variables. List names only -- NEVER include values.

- `[VAR_NAME]` - _[what it's for]_
- `[VAR_NAME]` - _[what it's for]_

**Secrets location:**
- _[Where secrets are stored]_ - Reference: `[path]`

## Webhooks

**Incoming:**
- _[Endpoint or "None"]_ - Handler in `[path]`

**Outgoing:**
- _[Endpoint or "None"]_ - Configured in `[path]`

## Quality Gate

Before considering this file complete, verify:
- [ ] Every finding includes at least one file path in backticks
- [ ] Voice is prescriptive ("Use X", "Place files in Y") not descriptive ("X is used")
- [ ] No section left empty -- use "Not detected" or "Not applicable"
- [ ] Environment variable names documented (NEVER values)
- [ ] Service categories complete (APIs, storage, auth, monitoring, deployment)
- [ ] File paths included for integration code
