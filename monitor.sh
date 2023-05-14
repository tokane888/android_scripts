#!/bin/bash              

set -ux
                         
log() {             
  local message="$1"                                                                                  
  echo "$(date "+%Y/%m/%d %H:%M:%S") $message" >> /data/adb/service.d/log/monitor.log
}                        
                         
is_connected_to_wan() {
  ip addr show dev wlan0 | grep inet
  if [ $? = 0 ]; then
    false
  else
    true
  fi
}

get_target_dns_ip() {
  log "$(nslookup joyhome.mydns.jp)"
  nslookup joyhome.mydns.jp | grep -A 2 -E "^Name:" | grep "." | tail -1 | cut -d' ' -f 3
}

main() {
  log "monitor started."
  export PATH=$PATH:/data/media/0/busybox_links
  export ASH_STANDALONE=1 

  while true
  do
    sleep 30
    local current_time="$(date +%H%M)"
    log "current_time: $current_time"

    if is_connected_to_wan; then
      getprop > /data/adb/service.d/log/getprop.log 

      if [ "$current_time" -gt "330" ] && [ "$current_time" -lt "2110" ]; then
        local target_dns_ip="$(get_target_dns_ip)"

        log "target_dns_ip=$target_dns_ip"
        log "getprop net.dns1=$(getprop net.dns1)"
        log "getprop net.dns2=$(getprop net.dns2)"

        if [ "$target_dns_ip" != "$(getprop net.dns1)" ]; then
          log "setprop net.dns1 $target_dns_ip"
          log "setprop net.dns2 $target_dns_ip"
          setprop net.dns1 $target_dns_ip
          setprop net.dns2 $target_dns_ip
        fi
      else
        local target_dns_ip="8.8.8.8"

        log "target_dns_ip=$target_dns_ip"
        log "getprop net.dns1=$(getprop net.dns1)"

        if [ "$target_dns_ip" != "$(getprop net.dns1)" ]; then
          log "setprop net.dns1 $target_dns_ip"
          setprop net.dns1 $target_dns_ip
          setprop net.dns2 $target_dns_ip
        fi
      else
        local target_dns_ip="8.8.8.8"

        log "target_dns_ip=$target_dns_ip"
        log "getprop net.dns1=$(getprop net.dns1)"

        if [ "$target_dns_ip" != "$(getprop net.dns1)" ]; then
          log "setprop net.dns1 $target_dns_ip"
          setprop net.dns1 $target_dns_ip
        fi
      fi
      getprop > /data/adb/service.d/log/getprop_after.log
    fi   
  done
}

main