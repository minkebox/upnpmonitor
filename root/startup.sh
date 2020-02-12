#! /bin/bash

touch /tmp/alltime
update() {
  raw="$(upnpc -L | grep -E '(UDP|TCP)')"
  #raw="$(cat tmp/testdata | grep -E '(UDP|TCP)')"
  echo "$raw" | while read map; do
    split=($map)
    #idx=${split[0]}
    protocol=${split[1]}
    mapping=${split[2]}
    fport="${mapping%%->*}"
    target="${mapping#*->}"
    ip="${target%%:*}"
    tport="${target#*:}"
    tag=$(echo ${split[3]} | sed "s/^'\(.*\)'$/\1/")
    #blank=${split[4]}
    #timeout=${split[5]}
    echo ${fport} ["${fport}/${protocol}","${ip}","${tport}","${tag}"]
  done > /tmp/active
  cat /tmp/alltime /tmp/active | sort -g | uniq > /tmp/alltime.new
  cp /tmp/alltime.new /tmp/alltime
  echo [$(cat /tmp/active | sort -g | sed "s/^[ 0-9]* //" | paste -s -d",")] > /tmp/active.display
  echo [$(cat /tmp/alltime | sort -g | sed "s/^[ 0-9]* //" | paste -s -d",")] > /tmp/alltime.display
}

while true; do
  update
  sleep 60
done
