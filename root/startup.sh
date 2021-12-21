#! /bin/bash

touch /tmp/alltime /tmp/active
update() {
  raw="$(upnpc -l | grep -E '(UDP|TCP)')"
  cp /dev/null /tmp/active
  if [ "${raw}" != "" ]; then
    echo "${raw}" | while read map; do
      split=($map)
      #idx=${split[0]}
      protocol=${split[1]}
      mapping=${split[2]}
      fport="${mapping%%->*}"
      target="${mapping#*->}"
      ip="${target%%:*}"
      tport="${target#*:}"
      note=$(echo ${split[@]:3:$(expr ${#split[@]}-5)} | sed "s/^'\(.*\)'$/\1/")
      #blank=${split[4]}
      #timeout=${split[5]}
      echo ${fport} ${protocol} ${tport} ${ip} ${note} >> /tmp/active
    done
  fi
  cat /tmp/alltime /tmp/active | sort -g | uniq > /tmp/alltime.new
  cp /tmp/alltime.new /tmp/alltime
  cat /tmp/alltime /tmp/active | sort | uniq -u > /tmp/inactive
  echo "$(cat /tmp/active)" | while read map; do
    if [ "$map" != "" ]; then
      v=($map)
      ip=${v[3]}
      hostname=$(nslookup ${ip} | grep name | sed "s/^.*name = \(.*\)$/\1/")
      if [ "${hostname}" = "" ]; then
        hostname=${ip}
      fi
      echo ${v[0]} [\"${v[0]}/${v[1]}\",\"${hostname}\",\"${v[2]}\",\"${v[4]}\"]
    fi
  done > /tmp/active.entries
  echo "$(cat /tmp/inactive)" | while read map; do
    if [ "$map" != "" ]; then
      v=($map)
      ip=${v[3]}
      hostname=$(nslookup ${ip} | grep name | sed "s/^.*name = \(.*\)$/\1/")
      if [ "${hostname}" = "" ]; then
        hostname=${ip}
      fi
      echo ${v[0]} [\"${v[0]}/${v[1]}\",\"${hostname}\",\"${v[2]}\",\"${v[4]}\"]
    fi
  done > /tmp/inactive.entries
  echo [$(cat /tmp/active.entries | sort -g | sed "s/^[ 0-9]* //" | paste -s -d",")] > /tmp/active.display
  echo [$(cat /tmp/inactive.entries | sort -g | sed "s/^[ 0-9]* //" | paste -s -d",")] > /tmp/inactive.display
}

trap "echo 'Terminating'; killall sleep upnpc; exit" TERM

while true; do
  update
  sleep 60 &
  wait "$!"
done
