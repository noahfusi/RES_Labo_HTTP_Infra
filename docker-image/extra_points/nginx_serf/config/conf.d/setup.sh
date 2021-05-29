#!/bin/bash
rm /etc/nginx/conf.d/static.conf
rm /etc/nginx/conf.d/dynamic.conf
touch /etc/nginx/conf.d/static.conf
touch /etc/nginx/conf.d/dynamic.conf
printf "server ${STATIC_IP};" >> /etc/nginx/conf.d/static.conf
printf "server ${DYNAMIC_IP}:3000;" >> /etc/nginx/conf.d/dynamic.conf