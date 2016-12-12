#!/bin/bash
#
# Updates the sites to the current external ip (as seen by zoneedit).

# Sites to be updated
SITES=('an.example.com' 'another.example.com')
# Zoneedit Username
ZONEEDIT_USERNAME="example"
# Zoneedit Password (auth token is recommended)
ZONEEDIT_PASSWORD="password"
# Path where the last kwnown address is stored (to avoid updating when not needed)
IP_CACHE_DIR="$HOME/.cache/"
# File where last known ip is stored
IP_CACHE_FILE="zoneedit_last_ip"
# Sites used to obtain the current external ip
IP_PROVIDERS=('icanhazip.com' 'wtfismyip.com/text' 'checkip.amazonaws.com' 'ipinfo.io/ip')

#Update IP address function, corrects settings on zoneedit.com
function updateip ()
{
	current_ip=$1
	for site in "${SITES[@]}"
	do
		wget -q -O - --http-user="${ZONEEDIT_USERNAME}" --http-passwd="${ZONEEDIT_PASSWORD}" "https://dynamic.zoneedit.com/auth/dynamic.html?host=${site}&dnsto=${current_ip}" > /dev/null 2>&1
	done
}

#Determine the current real ip address for this machine use a random provider from the list above.
IP_PROVIDER=${IP_PROVIDERS[$(( RANDOM % ${#IP_PROVIDERS[@]} ))]}
IP_CURRENT=$(wget -O - -q $IP_PROVIDER)

#Read in the current ip from currentip log file. Assign that value to a variable for comparison.
IP_CACHE_PATH="${IP_CACHE_DIR}/${IP_CACHE_FILE}"
if [ ! -f "$IP_CACHE_PATH" ]
then
	mkdir -p "$IP_CACHE_DIR"
	touch "$IP_CACHE_PATH"
fi

IP_LAST=$(cat "$IP_CACHE_PATH")

if [ "$IP_CURRENT" != "$IP_LAST" ] && [ "$IP_CURRENT" != "" ]
then
	updateip "$IP_CURRENT"
	echo "Updated ${SITES[*]} to ${IP_CURRENT}"
	echo "$IP_CURRENT" > "$IP_CACHE_PATH"
fi

