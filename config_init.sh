#!/bin/bash

# This script is used to print on screen the network settings of a Linux machine.
# You can specify the network interface name as an argument.
# Updated 06/04/2026

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Check if an argument is provided
if [ $# -eq 0 ]; then
  echo "Please provide the network interface name as an argument."
  exit 1
fi

# Store the argument in a variable
interface="$1"
printf "\n${YELLOW}[*] Today's Network Configuration${NC}\n\n"

printf "${GREEN}[*] Today's Date:${NC}\n\n"
echo "$(date)"
printf "\n"

printf "${GREEN}[*] Network Interface and IP:${NC}\n\n"
# ifconfig $1| grep -vE 'RX|TX'
ifconfig "$interface" 2>&1 | grep -vE 'RX|TX' | awk -v yellow="$YELLOW" -v red="$RED" -v nc="$NC" '{
  if ($0 ~ /Device not found/ || $0 ~ /error fetching interface information/) {
    print red $0 nc;
  } else {
    if ($1 == "inet") {
      for (i = 2; i <= NF; i++) {
        if ($i ~ /[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/) {
          $i = yellow $i nc;  # Highlight IP address
        }
      }
    }
    print;
  }
}'
printf "\n"

printf "${GREEN}[*] Route Information:${NC}\n\n"
route
printf "\n"

printf "${GREEN}[*] DNS Settings:${NC}\n\n"
nmcli dev show | grep 'IP4.DNS' | sed 's/IP4.DNS/DNS Server/g'
printf "\n"
cat /etc/resolv.conf | grep -vE ^#
printf "\n"

printf "${GREEN}[*] External IP:${NC}\n\n"
curl ifconfig.me
printf "\n"
printf "\n"

printf "${GREEN}[*] Default Gateway:${NC}\n\n"
ip route | grep default | awk '{print $3}'
printf "\n"
