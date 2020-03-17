#!/usr/bin/env bash

DOMAIN="$1"
API_KEY="$2"
EMAIL="$3"
DEST_EMAIL="$4"
HA_TOKEN="$5"

EMAIL_FWD=$(/usr/bin/curl --silent https://api.gandi.net/v5/email/forwards/${DOMAIN} \
  -H 'authorization: Apikey '${API_KEY}'' -H 'content-type: application/json' \
  -d '{"source":"'${EMAIL}'","destinations":["'${DEST_EMAIL}'"]}' --write-out "%{http_code}\n")

RESP_CODE=$(echo "${EMAIL_FWD##*\}}")

if [[ "${RESP_CODE}" = 201 ]]; then
  MSG="Woohhooo forwarding email ${EMAIL}@${DOMAIN} created!!!"
elif [[ "${RESP_CODE}" = 400 ]]; then
  MSG=$(echo "${EMAIL_FWD%\}*}}" | jq '.errors[].description' | tr -d '"')
elif [[ "${RESP_CODE}" = 401 ]]; then
  MSG="Lack of Permissions"
elif [[ "${RESP_CODE}" = 403 ]]; then
  MSG="Wrong API Key"
else
  MSG="Cannot recognise response code ${RESP_CODE}"
fi

/usr/bin/curl -X POST -H "Authorization: Bearer ${HA_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"state": '${RESP_CODE}',"attributes": {"message":"'"${MSG}"'"}}' \
  http://localhost:8123/api/states/sensor.curl_resp