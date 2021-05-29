#!/bin/bash
rm /etc/nginx/conf.d/static.conf
rm /etc/nginx/conf.d/dynamic.conf
touch /etc/nginx/conf.d/static.conf
touch /etc/nginx/conf.d/dynamic.conf
echo ${STATIC_IP} >> /etc/nginx/conf.d/static.conf
echo ${DYNAMIC_IP} >> /etc/nginx/conf.d/dynamic.conf