#!/bin/bash

set -e

export POSTGRESQL_HOST=$1
export REGISTRY_URL=$1:5000
export CHROME_BIN=chromium-browser
export DISPLAY=:99.0
sh -e /etc/init.d/xvfb start

cd ./src/portal && npm run lint && npm run lint:lib && npm run test && cd -
sudo docker-compose -f ./make/docker-compose.test.yml up -d
sleep 10
./tests/pushimage.sh
docker ps

go test -race -i ./src/core ./src/jobservice
sudo -E env "PATH=$PATH" "POSTGRES_MIGRATION_SCRIPTS_PATH=/home/travis/gopath/src/github.com/goharbor/harbor/make/migrations/postgresql/" ./tests/coverage4gotest.sh
set +e
goveralls -coverprofile=profile.cov -service=travis-ci