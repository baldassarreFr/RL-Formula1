# Base image
FROM python:3.12-slim

# System tools. They rarely change, so this layer comes first and stays cached
RUN apt-get update \
    && apt-get install -y --no-install-recommends git openssh-client \
    && rm -rf /var/lib/apt/lists/*

# Non-root user
RUN useradd -m -u 1000 -s /bin/bash dev

WORKDIR /workspace

# Python dependencies
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# From here on, everything runs as dev, not root
USER dev