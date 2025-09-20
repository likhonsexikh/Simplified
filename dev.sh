#!/bin/bash
# Development script for managing the AI Agent System
# This script is a wrapper around docker-compose for development purposes.

set -e

# The main docker-compose file for development
COMPOSE_FILE="docker-compose.dev.yml"

# Check if docker-compose is installed
if ! command -v docker-compose &> /dev/null
then
    echo "docker-compose could not be found. Please install it."
    exit 1
fi

# Pass all arguments to docker-compose
docker-compose -f "$COMPOSE_FILE" "$@"
