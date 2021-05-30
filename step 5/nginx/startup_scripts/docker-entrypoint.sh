#!bin/bash -e

rm -f /etc/nginx/conf.d/static.conf
rm -f /etc/nginx/conf.d/dynamic.conf
touch /etc/nginx/conf.d/static.conf
touch /etc/nginx/conf.d/dynamic.conf
printf "server ${STATIC_IP};" >> /etc/nginx/conf.d/static.conf
printf "server ${DYNAMIC_IP};" >> /etc/nginx/conf.d/dynamic.conf

for hook in $(ls /startup-hooks); do
  echo -n "Found startup hook ${hook} ... ";
  if [ -x "/startup-hooks/${hook}" ]; then
    echo "executing.";
    /startup-hooks/${hook};
  else
    echo 'not executable. Skipping.';
  fi
done

_quit () {
  echo 'Caught sigquit, sending SIGQUIT to child';
  kill -s QUIT $child;
}

trap _quit SIGQUIT;

echo 'Starting child (nginx)';
nginx -g 'daemon off;' &
child=$!;

echo 'Waiting on child...';
wait $child;