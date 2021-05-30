#!/bin/bash
if [ $SERF_TAG_ROLE != "lb" ]; then
    echo "Not an lb. Ignoring member leave"
    exit 0
fi

while read line; do
    ROLE=`echo $line | awk '{print $3 }'`

	IP_ADDRESS=`echo $line | awk '{print $2 }'`
	if [ $ROLE == "static"]; then 
		echo "Static server leaving"
		sed -i "/${IP_ADDRESS}/d" /etc/nginx/conf.d/static.conf
		exit 0
	fi
	if [ $ROLE == "dynamic"]; then
		echo "Dynamic server leaving"
		sed -i "/${IP_ADDRESS}/d" /etc/nginx/conf.d/dynamic.conf
		exit 0
	fi
done

systemctl reload nginx