#!/bin/bash

# Цвета
GREEN="\033[1;32m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
NC="\033[0m"

clear
echo -e "${CYAN}🌟 Welcome, $USER to $(hostname)! 🌟${NC}"
echo -e "${YELLOW}$(date)${NC}"

# neofetch
neofetch --color_blocks off --bold off

# Аптайм
echo -e "${GREEN}Uptime:${NC} $(uptime -p)"

# IP-адреса
IP=$(ip addr show | awk '/inet / && $2 !~ /^127/ { sub("/.*", "", $2); print $2; exit }')
WAN_IP=$(curl -s ifconfig.me)
GEOLOC=$(curl -s ipinfo.io/$WAN_IP/city)
echo -e "${GREEN}Local IP:${NC} $IP"
echo -e "${GREEN}WAN IP:${NC} $WAN_IP ($GEOLOC)"

# Температура CPU
TEMP=$(sensors | grep 'Package id 0:' | awk '{print $4}')
echo -e "${GREEN}CPU Temp:${NC} $TEMP"

# Загрузка
LOAD=$(uptime | awk -F'load average:' '{ print $2 }')
echo -e "${GREEN}Load:${NC} $LOAD"

# Память
free -h | awk '/Mem:/ {printf "'$GREEN'Memory Used:'$NC' %s / %s\n", $3, $2}'

# Диск
DISK_USAGE=$(df -h / | awk 'NR==2 {print $3 " / " $2 " used (" $5 ")"}')
echo -e "${GREEN}Disk (/):${NC} $DISK_USAGE"

# Последняя перезагрузка
BOOT_TIME=$(uptime -s)
echo -e "${GREEN}Last Boot:${NC} $BOOT_TIME"

# Обновления
if command -v checkupdates &> /dev/null; then
  UPDATES=$(checkupdates 2>/dev/null | wc -l)
  echo -e "${GREEN}Updates Available:${NC} $UPDATES"
fi

# Сервисы systemd
SERVICES=$(systemctl list-units --type=service --state=running | grep ".service" | wc -l)
echo -e "${GREEN}Active Services:${NC} $SERVICES"

# Docker-мониторинг
if command -v docker &> /dev/null; then
  TOTAL_CONTAINERS=$(docker ps -aq | wc -l)
  RUNNING_CONTAINERS=$(docker ps -q | wc -l)
  echo -e "${GREEN}Docker:${NC} $RUNNING_CONTAINERS running / $TOTAL_CONTAINERS total"

  echo -e "${GREEN}Monitored Services:${NC}"

  docker ps -a --format '{{.Names}}' | sort | while read -r CONTAINER; do
    DISPLAY_NAME=$(echo "$CONTAINER" | sed -E 's/(^|[-_])(.)/\U\2/g')

    STATUS=$(docker inspect -f '{{.State.Status}}' "$CONTAINER" 2>/dev/null)
    HEALTH=$(docker inspect -f '{{.State.Health.Status}}' "$CONTAINER" 2>/dev/null)

    case "$STATUS" in
      running)
        if [[ "$HEALTH" == "healthy" ]]; then
          ICON="✅"; COLOR=$GREEN
        elif [[ "$HEALTH" == "unhealthy" ]]; then
          ICON="🟡"; COLOR=$YELLOW
        else
          ICON="⚙️"; COLOR=$CYAN
        fi
        ;;
      restarting) ICON="🔁"; COLOR=$YELLOW ;;
      exited|dead) ICON="❌"; COLOR=$RED ;;
      paused) ICON="⏸️"; COLOR=$YELLOW ;;
      *) ICON="❔"; COLOR=$RED ;;
    esac

    printf "   ➤ %-28s: %b%s %b\n" "$DISPLAY_NAME" "$COLOR" "$STATUS" "$ICON$NC"
  done
else
  echo -e "${YELLOW}Docker not found.${NC}"
fi
