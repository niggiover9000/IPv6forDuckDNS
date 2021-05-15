# IPv6forDuckDNS
Script to submit IPv6 only to DuckDNS.

By default, DuckDNS cannot automatically resolve IPv6 addresses (See [DuckDNS FAQ](https://www.duckdns.org/faqs.jsp) for more details.) Using my script will allow you to easily and automatically submit your IPv6 address to DuckDNS.

# Understanding IPv6
While your public IPv4 address is shared across all devices in your network using NAT, each device will have its own public IPv6 address. Therefor, you must run this script on the device that is actually providing the service.

# Prerequisites
* curl, sed, grep, head
* working ipv6 address
* working internet connection w/ dns resolution

# Installation
1. Run **./autoconfig-duckdns6.sh**
   * Type your site subdomain. *Do not enter ".duckdns.org."*
   * Paste your DuckDNS token. *Watch for trailing whitespace.*
   * If behind NAT, you'll be asked to enter an IPv4 service. *If you are unsure, just press Enter.*
1. The curl request should return OK when Connecting to Duck DNS.
   *  "K0" is an official error code from DuckDNS - check your subdomain and token
   * If you get any other output, something is broken. *See prerequisites.*
1. The script will automatically save your configuration in ~/ and create a cron job.
1. Check your crontab to make sure the job has been created.
