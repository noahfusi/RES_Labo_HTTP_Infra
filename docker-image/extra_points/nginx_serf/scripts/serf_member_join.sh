#!/bin/bash
if [ $SERF_TAG_ROLE != "lb" ]; then
    echo "Not an lb. Ignoring member join."
    exit 0
fi

while read line; do
    ROLE=`echo $line | awk '{print $3 }'`
	
	if [ $ROLE == "static" ]; then
		echo "Static server join"
		echo "$line" | awk '{ printf "server %s;\n", $2 }' >>/etc/nginx/conf.d/static.conf
		exit 0
	fi
	
	if [ $ROLE == "dynamic" ]; then
		echo "Dynamic server join"
		echo "$line" | awk '{ printf "server %s:3000;\n", $2 }' >>/etc/nginx/conf.d/dynamic.conf
		exit 0
	fi
done

systemctl reload nginx