#!/usr/bin/env bash

HA_TOKEN="$1"

STRING_CHECK="Your internet traffic is secure"
VPN_URL="https://nordvpn.com/what-is-my-ip/"
SENSOR_API="http://localhost:8123/api/states/sensor.vpn_error"

VPN_RESULT=$(/usr/bin/curl ${VPN_URL} 2>/dev/null > vpn.html && grep -E -o ${STRING_CHECK} vpn.html && rm vpn.html)

if [[ ${VPN_RESULT} = 'Your internet traffic is secure' ]]
then
  SENSOR_STATE=$(/usr/bin/curl -X GET -H "Authorization: Bearer ${HA_TOKEN}" ${SENSOR_API} 2>/dev/null | jq '.state')
  if [[ ${SENSOR_STATE} = "on" ]]
  then 
      /usr/bin/curl -X POST -H "Authorization: Bearer ${HA_TOKEN}" \
        -H "Content-Type: application/json" \
        -d '{"state": "off"}' ${SENSOR_API}
  fi
else
  /usr/bin/curl -X POST -H "Authorization: Bearer ${HA_TOKEN}" \
    -H "Content-Type: application/json" \
    -d '{"state": "on"}' ${SENSOR_API}
fi