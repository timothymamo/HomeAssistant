#!/bin/bash

for filename in /Users/timmamo/git/personal/unibond7/home-assistant/automations/*.yaml; do
    for line_number in $(awk '/^- alias:/{ print NR }' $filename); do
        line=$(head -$line_number $filename | tail +$line_number)
        str_alias=$(echo $line | sed "s/-/ /g")
        str_id=$(echo ${line#"- alias: "} | sed "s/'//g" | tr '[:upper:]' '[:lower:]' | tr -s ' ' '_')
        str_mod="- id: $str_id"
        sed -i -e "s|$line|$str_mod$str_alias|" $filename
    done
done
