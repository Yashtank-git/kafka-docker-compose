#!/bin/bash

apt update
apt install curl jq -y

TOKEN=$(curl --location --request POST 'immudb-api:3323/login' \
--header 'Authorization;' \
--header 'Content-Type: application/json' \
--data-raw '{
    "user": "aW1tdWRi",
    "password": "aW1tdWRi"
}' |  jq -r .token)


curl -X POST \
  http://immudb-api:3323/db/defaultdb/create \
  -H 'Content-Type: application/json' \
  -H 'Authorization: '$TOKEN'' \
  -d '{"databaseName":"dataverse"}'


curl -X POST \
  http://immudb-api:3323/user \
  -H 'Content-Type: application/json' \
  -H 'Authorization: '$TOKEN'' \
  -d '{"user":"ZGF0YXZlcnNl","password":"REFUQV8xMjM0","permission":254,"database":"dataverse"}'


curl -X POST \
  http://immudb-api:3323/user/changepermission \
  -H 'Content-Type: application/json' \
  -H 'Authorization: '$TOKEN'' \
  -d '{"properties":"GRANT","username":"dataverse","permission":1,"database":"defaultdb"}'


sleep infinity

