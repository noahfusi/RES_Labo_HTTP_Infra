if [ $SERF_TAG_ROLE != "lb" ]; then
    echo "Not an lb. Ignoring member leave"
    exit 0
fi

while read line; do
    ROLE=`echo $line | awk '{print $3 }'`
    if [ $ROLE != "web" ]; then
        echo "Not a webserver. Ignoring member join."
        exit 0
    fi

    IP_ADDRESS=`echo $line | awk '{print $2 }'`
    sed -i "/${IP_ADDRESS}/d" /etc/nginx/conf.d/static.conf
done

systemctl reload nginx