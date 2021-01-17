#!/bin/bash
# shellcheck source=/dev/null
# Autoconfig for DuckDNS IPv6 Update Script v0.1
# Based on the project of James Watt
# Edited to only update IPv6.
set -e

# Paths
baseDir=$(cd "$(dirname "$0")" || exit; pwd -P)
duck6conf="$HOME"/.duck6.conf

# Probe IPv4 and IPv6 addresses
read -r _ _ _ _ iface _ ipv4local <<<"$(ip r g 8.8.8.8 | head -1)"
ipv6addr=$(ip addr show dev "$iface" | sed -e's/^.*inet6 \([^ ]*\)\/.*$/\1/;t;d' | grep -v '^fd00' | grep -v '^fe80' | head -1)

# Does .duck6.conf exist?
if [[ -f "$duck6conf" ]] ; then
  source "$duck6conf"
else
  # Questions
  printf "Autoconfigure script by James Watt for DuckDNS.\nThis script should be run on the computer hosting the services you would like publicly accessible.\n\nCheck https://www.duckdns.org/domains for domain and token\n\n"
  read -r -e -p "DuckDNS Subdomain (Do not include \".duckdns.org\"): " duckdomain
  read -r -e -p "DuckDNS Token (E.g. a7c4d0ad-114e-40ef-ba1d-d217904a50f2): " ducktoken
fi
  
# Connect to DuckDNS
printf "\nNow connecting to DuckDNS and pushing your IPv6 $ipv6addr"
printf "\nfor domain $duckdomain.duckdns.org with Token $ducktoken."
echo url="https://www.duckdns.org/update?domains=$duckdomain&token=$ducktoken&ipv6=$ipv6addr&verbose=True" | curl -k -o ~/duckdns/duck.log -K -

# Write changes and create cronjob

if [[ -f "$duck6conf" ]] ; then
  exit
else
  printf "\n\nCheck https://www.duckdns.org/domains to ensure it updated with the correct info.\n\n"
  yesNo="Y"
  read -r -e -p "Did it update correctly? [Y/n]" RyesNo
  yesNo=${RyesNo:-$yesNo}
  if [[ "$yesNo" == "Y" || "$yesNo" == "y" || "$yesNo" == "yes" || "$yesNo" == "Yes" ]] ; then
    printf "\n 1. Writing changes to ~/duck6.conf."
    echo "#IPv6 for DuckDNS Config Script. You can make changes to this file." > "$duck6conf"
    {
      echo duckdomain=\""$duckdomain"\"
      echo ducktoken=\""$ducktoken"\"
      echo ipv4service=\""$ipv4service"\"
    } >> "$duck6conf"
    printf "\n 2. Copying this script to ~/duckdns6.sh"
    cp "$baseDir"/autoconf-duckdns6.sh "$HOME"/duckdns6.sh
    printf "\n 3. Setting up cronjob to run every 5 minutes"
    (crontab -l 2>/dev/null; echo "*/5 * * * * ~/duckdns6.sh >/dev/null 2>&1") | crontab -
    printf "\n\nConfiguration complete.\n"
  else
    printf "\n\nThis script will now exit. Please double check your settings and run ./autoconfig-duckdns6.sh again.\n\n"
    exit
  fi
fi
