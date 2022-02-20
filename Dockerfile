# syntax=gcr.io/host-project-f966/dockerfile:1
# Build step
FROM gcr.io/host-project-f966/python-builder-base:v1 AS builder
WORKDIR /app

# Copy Source
COPY . /app

ENV VIRTUAL_ENV=/app/.venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
ENV PYTHONPATH="/app"
# Setup python virtual environment to get packages from artifact registry
RUN rm -rf /app/.venv &&\
    pyvirtinit

ENV GOOGLE_APPLICATION_CREDENTIALS=/app/gcp-creds
RUN --mount=type=secret,required=true,id=gcp-creds,target=/app/gcp-creds pip install --no-cache-dir -r /app/requirements.txt


# Package Step
FROM us-central1-docker.pkg.dev/dev-env-0884/lumiata-dev-container-registry/python:3.7-slim-buster AS package

WORKDIR /app

ENV VIRTUAL_ENV=/app/.venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
ENV PYTHONPATH="/app"

# Copy files from builder container
COPY --from=builder /app .
