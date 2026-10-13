#!/bin/bash

INSTALL_DIR="$HOME/Desktop/watchdog"

RED="\033[91m"
GREEN="\033[92m"
YELLOW="\033[93m"
RESET="\033[0m"

echo -e "${GREEN}[+] Installing watchdog...${RESET}"

mkdir -p "$INSTALL_DIR"
chmod +x ./watchdog.sh
cp watchdog.sh "$INSTALL_DIR"

echo -e "${GREEN}[+] Installation completed.${RESET}"
echo -e "${YELLOW}[*] Project directory: $INSTALL_DIR${RESET}"
echo -e "${YELLOW}[*] Run: $INSTALL_DIR/watchdog -h${RESET}"
