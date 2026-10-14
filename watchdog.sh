#!/bin/bash

set -eo pipefail

#set color
RED="\033[91m"
GREEN="\033[92m"
YELLOW="\033[93m"
BLUE="\033[94m"
CYAN="\033[96m"
RESET="\033[0m"


#files path modification
DOMAIN="$2"
OLD_DIR="$HOME/Desktop/watchdog/"$DOMAIN".old_dir.txt"
NEW_DIR="$HOME/Desktop/watchdog/"$DOMAIN".new_dir.txt"
CHANGE_DIR="$HOME/Desktop/watchdog/"$DOMAIN".change.dir.txt"
DIRECTORY_DICTIONARY="$HOME/Desktop/source/dictionary/combined_directory.txt"
OLD_SUB="$HOME/Desktop/watchdog/"$DOMAIN".old_sub.txt"
NEW_SUB="$HOME/Desktop/watchdog/"$DOMAIN".new_sub.txt"
CHANGE_SUB="$HOME/Desktop/watchdog/"$DOMAIN".change.sub.txt"
SUBDOMAIN_DICTIONARY="$HOME/Desktop/source/dictionary/subs.txt"

#check watch_dog directory exist
start_function() {
	if [[ $# -ne 2 ]]; then
        	usage
        	exit 1
    	fi

        printf "starting WatchDog on target:%s\n" "$DOMAIN"
}

#check directory change file exist
check_directory_change_exist() {
if [ ! -f "$CHANGE_DIR" ]; then
	touch "$CHANGE_DIR"
fi
}

#check subdomain change file exist
check_subdomain_change_exist() {
if [ ! -f "$CHANGE_SUB" ]; then
        touch "$CHANGE_SUB"
fi
} 


#check if old directory file exist
check_old_directory_exist() {
if [ ! -f "$OLD_DIR" ]; then
	ffuf -rate 500 -ac -s -u https://"$DOMAIN"/FUZZ -mc 200-299,301,302,401,403,405,500  -w "$DIRECTORY_DICTIONARY" -of csv -o ~/Desktop/watchdog/dir.csv
	tail -n +2 ~/Desktop/watchdog/dir.csv | cut -d',' -f1 > "$OLD_DIR"
	sort -u "$OLD_DIR" -o "$OLD_DIR"
	rm ~/Desktop/watchdog/dir.csv
fi
}

#check if old subdomain file exist
check_old_subdomain_exist() {
if [ ! -f "$OLD_SUB" ]; then
        ffuf -rate 500 -ac -s -u https://FUZZ."$DOMAIN" -mc 200-299,301,302,401,403,405,500  -w "$SUBDOMAIN_DICTIONARY" -of csv -o ~/Desktop/watchdog/sub.csv
        tail -n +2 ~/Desktop/watchdog/sub.csv | cut -d',' -f1 > "$OLD_SUB"
        sort -u "$OLD_SUB" -o "$OLD_SUB"
        rm ~/Desktop/watchdog/sub.csv
fi
}

#find new directories
find_new_directory() {
ffuf -rate 500 -ac -s -u https://"$DOMAIN"/FUZZ -mc 200-299,301,302,401,403,405,500  -w "$DIRECTORY_DICTIONARY" -of csv -o ~/Desktop/watchdog/new_dir.csv
tail -n +2 ~/Desktop/watchdog/new_dir.csv | cut -d',' -f1 > "$NEW_DIR"
sort -u "$NEW_DIR" -o "$NEW_DIR"
rm ~/Desktop/watchdog/new_dir.csv
}

#find new subdomains
find_new_subdomain() {
ffuf -rate 500 -ac -s -u https://FUZZ."$DOMAIN" -mc 200-299,301,302,401,403,405,500  -w "$SUBDOMAIN_DICTIONARY" -of csv -o ~/Desktop/watchdog/new_sub.csv
tail -n +2 ~/Desktop/watchdog/new_sub.csv | cut -d',' -f1 > "$NEW_SUB"
sort -u "$NEW_SUB" -o "$NEW_SUB"
rm ~/Desktop/watchdog/new_sub.csv
}


#check for directory change and action
check_dir_change_and_action() {
if cmp -s "$OLD_DIR" "$NEW_DIR"; then
	echo "[date] $(date '+%Y-%m-%d %H:%M:%S')" >> "$CHANGE_DIR"
	echo "[does not find any change]" >> "$CHANGE_DIR"
	rm "$NEW_DIR"
else
	echo "[date] $(date '+%Y-%m-%d %H:%M:%S')" >> "$CHANGE_DIR"
	comm -13 <(sort "$OLD_DIR") <(sort "$NEW_DIR") | sed 's/^/[add] /' >> "$CHANGE_DIR"
	comm -23 <(sort "$OLD_DIR") <(sort "$NEW_DIR") | sed 's/^/[delete] /' >> "$CHANGE_DIR"
	rm "$OLD_DIR"
	mv "$NEW_DIR" "$OLD_DIR"

fi
}

#check for subdomain change and action
check_sub_change_and_action() {
if cmp -s "$OLD_SUB" "$NEW_SUB"; then
		echo "[date] $(date '+%Y-%m-%d %H:%M:%S')" >> "$CHANGE_SUB"
		echo "[does not find any change]"  >> "$CHANGE_SUB"
        rm "$NEW_SUB"
else
        echo "[date] $(date '+%Y-%m-%d %H:%M:%S')" >> "$CHANGE_SUB"
        comm -13 <(sort "$OLD_SUB") <(sort "$NEW_SUB") | sed 's/^/[add] /' >> "$CHANGE_SUB"
        comm -23 <(sort "$OLD_SUB") <(sort "$NEW_SUB") | sed 's/^/[delete] /' >> "$CHANGE_SUB"
        rm "$OLD_SUB"
        mv "$NEW_SUB" "$OLD_SUB"

fi
}


usage() {
    printf '\033[91m'
    printf '██╗    ██╗ █████╗ ████████╗ ██████╗██╗  ██╗██████╗  ██████╗  ██████╗\n'
    printf '██║    ██║██╔══██╗╚══██╔══╝██╔════╝██║  ██║██╔══██╗██╔═══██╗██╔════╝\n'
    printf '██║ █╗ ██║███████║   ██║   ██║     ███████║██║  ██║██║   ██║██║  ███╗\n'
    printf '██║███╗██║██╔══██║   ██║   ██║     ██╔══██║██║  ██║██║   ██║██║   ██║\n'
    printf '╚███╔███╔╝██║  ██║   ██║   ╚██████╗██║  ██║██████╔╝╚██████╔╝╚██████╔╝\n'
    printf ' ╚══╝╚══╝ ╚═╝  ╚═╝   ╚═╝    ╚═════╝╚═╝  ╚═╝╚═════╝  ╚═════╝  ╚═════╝\n'
    printf '\033[0m\n'

    printf 'Directory & Subdomain Change Detector\n\n'
    printf 'Usage: %s {-dir|-sub} <domain>\n' "$0"
    printf 'Example: %s -dir example.com\n' "$0"
    printf '         %s -sub example.com\n' "$0"
}

case "$1" in

        -dir)
		start_function "$@"
		check_directory_change_exist
		check_old_directory_exist
		find_new_directory
		check_dir_change_and_action
                ;;

        -sub)
                start_function "$@"
                check_subdomain_change_exist
                check_old_subdomain_exist
                find_new_subdomain
                check_sub_change_and_action
                ;;

	-h|-help)
		usage
		;;

        *)
                usage
                ;;
esac

