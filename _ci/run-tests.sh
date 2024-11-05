#!/bin/bash
# Runs the automated tests for this repo

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

echo "Building docker containers for test"
docker build -t nholuongut/nholuongut-installer-ubuntu test/ubuntu
docker build -t nholuongut/nholuongut-installer-ubuntu18 test/ubuntu18
docker build -t nholuongut/nholuongut-installer-amazonlinux test/amazonlinux
docker build -t nholuongut/nholuongut-installer-centos test/centos
docker build -t nholuongut/nholuongut-installer-no-sudo-ubuntu test/no_sudo

echo "Running integration tests using docker-compose"
docker-compose -f test/ubuntu/docker-compose.yml run installer /test/integration-test.sh
docker-compose -f test/ubuntu18/docker-compose.yml run installer /test/integration-test.sh
docker-compose -f test/amazonlinux/docker-compose.yml run installer /test/integration-test.sh
docker-compose -f test/centos/docker-compose.yml run installer /test/integration-test.sh
docker-compose -f test/no_sudo/docker-compose.yml run installer /test/no-sudo-test.sh
