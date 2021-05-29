if [ $SERF_TAG_ROLE != "lb" ]; then
    echo "Not an lb. Ignoring member join."
    exit 0
fi

while read line; do
    ROLE=`echo $line | awk '{print $3 }'`
    if [ $ROLE != "web" ]; then
        echo "Not a webserver. Ignoring member join."
        exit 0
    fi

    echo "$line" | awk '{ printf "server %s;\n", $2 }' >>/etc/nginx/conf.d/static.conf
done

systemctl reload nginx