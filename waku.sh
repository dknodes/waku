#!/bin/bash

# ----------------------------
# Color and Icon Definitions
# ----------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
RESET='\033[0m'

CHECKMARK="✅"
ERROR="❌"
PROGRESS="⏳"
INSTALL="🛠️"
STOP="⏹️"
RESTART="🔄"
LOGS="📄"
EXIT="🚪"
INFO="ℹ️"

# ----------------------------
# Display ASCII Art (Header)
# ----------------------------
display_ascii() {
    clear
    echo -e "    ${RED}    ____  __ __    _   ______  ____  ___________${RESET}"
    echo -e "    ${GREEN}   / __ \\/ //_/   / | / / __ \\/ __ \\/ ____/ ___/${RESET}"
    echo -e "    ${BLUE}  / / / / ,<     /  |/ / / / / / / / __/  \\__ \\ ${RESET}"
    echo -e "    ${YELLOW} / /_/ / /| |   / /|  / /_/ / /_/ / /___ ___/ / ${RESET}"
    echo -e "    ${MAGENTA}/_____/_/ |_|  /_/ |_/\____/_____/_____//____/  ${RESET}"
    echo -e "    ${MAGENTA}🚀 Follow us on Telegram: https://t.me/dknodes${RESET}"
    echo -e "    ${MAGENTA}📢 Follow us on Twitter: https://x.com/dknodes${RESET}"
    echo -e "    ${GREEN}Welcome to the Waku Node Management System!${RESET}"
    echo -e ""
}

# ----------------------------
# Install Docker
# ----------------------------
install_docker() {
    echo -e "${INSTALL} Installing Docker...${RESET}"
    
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    echo -e "${CHECKMARK} Docker installed successfully.${RESET}"
    read -p "Press Enter to return to the main menu..."
}

# ----------------------------
# Install/Start Waku Node
# ----------------------------
install_waku() {
    echo -e "${INSTALL} Installing/Starting Waku node...${RESET}"
    
    if [ -d "nwaku-compose" ]; then
        echo -e "${INFO} 'nwaku-compose' directory already exists. Updating repository..."
        cd nwaku-compose || return
        git pull origin master
    else
        git clone https://github.com/waku-org/nwaku-compose
        cd nwaku-compose || return
    fi
    
    docker compose up -d
    echo -e "${CHECKMARK} Waku node started successfully.${RESET}"
    cd ..
    read -p "Press Enter to return to the main menu..."
}

# ----------------------------
# Edit .env File
# ----------------------------
edit_env() {
    echo -e "${INFO} Opening .env file with nano...${RESET}"
    if [ -d "nwaku-compose" ]; then
        cd nwaku-compose || return
        if [ ! -f ".env" ]; then
            echo -e "${INFO} .env file not found. Creating a new one..."
            touch .env
        fi
        nano .env
        cd ..
    else
        echo -e "${ERROR} 'nwaku-compose' directory not found. Please install the Waku node first."
    fi
    read -p "Press Enter to return to the main menu..."
}

# ----------------------------
# Restart Containers
# ----------------------------
docker_restart() {
    echo -e "${RESTART} Restarting containers via 'docker compose restart'...${RESET}"
    if [ -d "nwaku-compose" ]; then
        cd nwaku-compose || return
        docker compose restart
        cd ..
        echo -e "${CHECKMARK} Containers restarted successfully."
    else
        echo -e "${ERROR} 'nwaku-compose' directory not found. Please install the Waku node first."
    fi
    read -p "Press Enter to return to the main menu..."
}

# ----------------------------
# View Logs
# ----------------------------
view_logs() {
    echo -e "${LOGS} Viewing Waku node logs...${RESET}"
    if [ -d "nwaku-compose" ]; then
        cd nwaku-compose || return
        docker compose logs --tail 50
        cd ..
    else
        echo -e "${ERROR} 'nwaku-compose' directory not found. Please install the Waku node first."
    fi
    read -p "Press Enter to return to the main menu..."
}

# ----------------------------
# Stop Waku Node
# ----------------------------
stop_node() {
    echo -e "${STOP} Stopping Waku node...${RESET}"
    if [ -d "nwaku-compose" ]; then
        cd nwaku-compose || return
        docker compose down
        cd ..
        echo -e "${CHECKMARK} Waku node stopped successfully."
    else
        echo -e "${ERROR} 'nwaku-compose' directory not found."
    fi
    read -p "Press Enter to return to the main menu..."
}

# ----------------------------
# Update Waku Node
# ----------------------------
update_waku() {
    echo -e "${INFO} Updating Waku node...${RESET}"
    if [ -d "nwaku-compose" ]; then
        cd nwaku-compose || return
        echo -e "${INFO} Shutting down services..."
        docker-compose down
        echo -e "${INFO} Pulling latest changes from master..."
        git pull origin master
        echo -e "${INFO} Starting services..."
        docker-compose up -d
        cd ..
        echo -e "${CHECKMARK} Waku node updated successfully."
    else
        echo -e "${ERROR} 'nwaku-compose' directory not found. Please install the Waku node first."
    fi
    read -p "Press Enter to return to the main menu..."
}

# ----------------------------
# Check Node Health
# ----------------------------
check_health() {
    echo -e "${INFO} Checking node health with ./chkhealth.sh...${RESET}"
    if [ -x "./chkhealth.sh" ]; then
        ./chkhealth.sh
    else
        echo -e "${ERROR} Health check script ./chkhealth.sh not found or not executable."
    fi
    read -p "Press Enter to return to the main menu..."
}

# ----------------------------
# Main Menu
# ----------------------------
show_menu() {
    clear
    display_ascii
    echo -e "    ${YELLOW}Choose an operation:${RESET}"
    echo -e "    ${CYAN}1.${RESET} ${INSTALL} Install Docker"
    echo -e "    ${CYAN}2.${RESET} ${INSTALL} Install/Start Waku Node"
    echo -e "    ${CYAN}3.${RESET} ${INFO} Edit .env File"
    echo -e "    ${CYAN}4.${RESET} ${RESTART} Restart Containers"
    echo -e "    ${CYAN}5.${RESET} ${LOGS} View Logs"
    echo -e "    ${CYAN}6.${RESET} ${STOP} Stop Waku Node"
    echo -e "    ${CYAN}7.${RESET} ${INFO} Update Waku Node"
    echo -e "    ${CYAN}8.${RESET} ${INFO} Check Node Health"
    echo -e "    ${CYAN}9.${RESET} ${EXIT} Exit"
    echo -ne "    ${YELLOW}Enter your choice [1-9]: ${RESET}"
}

# ----------------------------
# Main Loop
# ----------------------------
while true; do
    show_menu
    read -r choice
    case $choice in
        1) install_docker ;;
        2) install_waku ;;
        3) edit_env ;;
        4) docker_restart ;;
        5) view_logs ;;
        6) stop_node ;;
        7) update_waku ;;
        8) check_health ;;
        9)
            echo -e "${EXIT} Exiting..."
            exit 0
            ;;
        *)
            echo -e "${ERROR} Invalid option. Please try again.${RESET}"
            read -p "Press Enter to continue..."
            ;;
    esac
done
