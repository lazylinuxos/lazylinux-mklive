#!/usr/bin/env bash

readonly DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Icon path
readonly ICON="${DIR}/icons/network/globe.svg"

# Displays network interface dengan ipv4 (local)
readonly TOOLTIP=$(ship --ipv4)

# Offline
ip route | grep ^default &>/dev/null || \
  echo -ne "<txt> Offline</txt>" || \
    echo -ne "<tool> Offline</tool>" || \
      exit

function hasil_untuk_panel () {

  local BANDWIDTH="${1}"
  local P=1

  while [[ $(echo "${BANDWIDTH}" '>' 1024 | bc -l) -eq 1 ]]; do
    BANDWIDTH=$(awk '{$1 = $1 / 1024; printf "%.2f", $1}' <<< "${BANDWIDTH}")
    P=$(( P + 1 ))
  done

  case "${P}" in
    0) BANDWIDTH="${BANDWIDTH} B/s" ;;
    1) BANDWIDTH="${BANDWIDTH} KB/s" ;;
    2) BANDWIDTH="${BANDWIDTH} MB/s" ;;
    3) BANDWIDTH="${BANDWIDTH} GB/s" ;;
  esac

  echo -e "${BANDWIDTH}"

  return 1
}

INTERFACES=( $(ship --ipv4 | awk '{ print $1 }') )

TX=""

for i in "${!INTERFACES[@]}";
do
  INTERFACE="${INTERFACES[$i]}"
  if [[ $INTERFACE =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    continue
  fi
  # Interface unknown
  test -d "/sys/class/net/${INTERFACE}" || \
    echo -ne "<txt>Invalid</txt>" || \
      echo -ne "<tool>Interface not found</tool>" || \
        exit

  PTX=$(awk '{print $0}' "/sys/class/net/${INTERFACE}/statistics/tx_bytes")
  sleep 1
  CTX=$(awk '{print $0}' "/sys/class/net/${INTERFACE}/statistics/tx_bytes")

  BTX=$(( CTX - PTX ))
  if [ "$i" -gt 0 ]; then
      TX+=" | "
  fi
  TX+=$(hasil_untuk_panel ${BTX})
done


# Panel
if [[ $(file -b "${ICON}") =~ PNG|SVG ]]; then
  INFO="<img>${ICON}</img>"
  if hash wireshark &> /dev/null; then
    INFO+="<click>wireshark</click>"
  fi
  INFO+="<txt>"
else
  INFO="<txt>"
fi
INFO+=" ${TX}"
INFO+="</txt>"

# Tooltip
MORE_INFO="<tool>"
MORE_INFO+="${TOOLTIP}"
MORE_INFO+="</tool>"

# Panel Print
echo -e "${INFO}"

# Tooltip Print
echo -e "${MORE_INFO}"
