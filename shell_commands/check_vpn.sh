#!/usr/bin/env bash

HA_TOKEN="$1"
IP_CHECK="$2"

VPN_URL="http://icanhazip.com/"
SENSOR_API="http://localhost:8123/api/states/sensor.vpn_error"

VPN_RESULT=$(/usr/bin/curl "${VPN_URL}" 2>/dev/null)

if [[ "${VPN_RESULT}" = "${IP_CHECK}" ]]
then
  SENSOR_STATE=$(/usr/bin/curl -X GET -H "Authorization: Bearer ${HA_TOKEN}" "${SENSOR_API}" 2>/dev/null | jq '.state')
  if [[ "${SENSOR_STATE}" != "off" ]]
  then 
      /usr/bin/curl -X POST -H "Authorization: Bearer ${HA_TOKEN}" \
        -H "Content-Type: application/json" \
        -d '{"state": "off","attributes": {"friendly_name":"VPN Error Check","message":"'"${VPN_RESULT}"'"}}' "${SENSOR_API}"
  fi
else
  /usr/bin/curl -X POST -H "Authorization: Bearer ${HA_TOKEN}" \
    -H "Content-Type: application/json" \
    -d '{"state": "on","attributes": {"friendly_name":"VPN Error Check","message":"'"${VPN_RESULT}"'"}}' "${SENSOR_API}"
fi