#!/bin/bash
# =====================================================
# TSP NODES – Advanced MOTD Installer (VPS + WSL)
# =====================================================

set -e

echo "🔧 Installing TSP NODES MOTD..."

# Ensure directory exists
sudo mkdir -p /etc/update-motd.d

# Disable default Ubuntu MOTD scripts
sudo chmod -x /etc/update-motd.d/* 2>/dev/null || true

# -----------------------------------------------------
# Create MOTD script
# -----------------------------------------------------
sudo tee /etc/update-motd.d/00-tspnodes >/dev/null <<'EOF'
#!/bin/bash

CYAN="\e[38;5;45m"
GREEN="\e[38;5;82m"
YELLOW="\e[38;5;220m"
BLUE="\e[38;5;51m"
RESET="\e[0m"

LOAD=$(uptime | awk -F 'load average:' '{print $2}' | awk '{print $1}')
MEM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
MEM_USED=$(free -m | awk '/Mem:/ {print $3}')
MEM_PERC=$((MEM_USED * 100 / MEM_TOTAL))
DISK_USED=$(df -h / | awk 'NR==2 {print $3}')
DISK_TOTAL=$(df -h / | awk 'NR==2 {print $2}')
DISK_PERC=$(df -h / | awk 'NR==2 {print $5}')
PROC=$(ps aux | wc -l)
USERS=$(who | wc -l)
IP=$(hostname -I | awk '{print $1}')
UPTIME=$(uptime -p | sed 's/up //')

echo -e "${CYAN}┌──────────────────────────────────────────────────────────────┐"
echo -e "│ ████████╗███████╗██████╗     ███╗   ██╗ ██████╗ ██████╗ ███████╗ │"
echo -e "│ ╚══██╔══╝██╔════╝██╔══██╗    ████╗  ██║██╔═══██╗██╔══██╗██╔════╝ │"
echo -e "│    ██║   ███████╗██████╔╝    ██╔██╗ ██║██║   ██║██║  ██║█████╗   │"
echo -e "│    ██║   ╚════██║██╔═══╝     ██║╚██╗██║██║   ██║██║  ██║██╔══╝   │"
echo -e "│    ██║   ███████║██║         ██║ ╚████║╚██████╔╝██████╔╝███████╗│"
echo -e "│    ╚═╝   ╚══════╝╚═╝         ╚═╝  ╚═══╝ ╚═════╝ ╚═════╝ ╚══════╝│"
echo -e "└──────────────────────────────────────────────────────────────┘${RESET}"

echo -e "${GREEN} Welcome to TSP NODES Datacenter! 🚀 ${RESET}\n"

echo -e "${BLUE}📊 System Information:${RESET} (as of $(date))\n"
printf "  ${YELLOW}CPU Load     :${RESET} %s\n" "$LOAD"
printf "  ${YELLOW}Memory Usage :${RESET} %sMB / %sMB (%s%%)\n" "$MEM_USED" "$MEM_TOTAL" "$MEM_PERC"
printf "  ${YELLOW}Disk Usage   :${RESET} %s / %s (%s)\n" "$DISK_USED" "$DISK_TOTAL" "$DISK_PERC"
printf "  ${YELLOW}Processes    :${RESET} %s\n" "$PROC"
printf "  ${YELLOW}Users Logged :${RESET} %s\n" "$USERS"
printf "  ${YELLOW}IP Address   :${RESET} %s\n" "$IP"
printf "  ${YELLOW}Uptime       :${RESET} %s\n\n" "$UPTIME"

echo -e "${CYAN}Support: support@tsplegend.xyz${RESET}"
echo -e "Website: ${BLUE}tsplegend.xyz${RESET}"
echo -e "${GREEN}Power. Performance. Reliability.${RESET}"
EOF

sudo chmod +x /etc/update-motd.d/00-tspnodes

# -----------------------------------------------------
# WSL FIX – run MOTD on SSH login
# -----------------------------------------------------
if grep -qi microsoft /proc/version; then
  echo "⚠ WSL detected – enabling SSH MOTD hook"

  USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
  mkdir -p "$USER_HOME/.ssh"

  tee "$USER_HOME/.ssh/rc" >/dev/null <<'EOF'
#!/bin/bash
run-parts /etc/update-motd.d
EOF

  chmod 700 "$USER_HOME/.ssh"
  chmod 600 "$USER_HOME/.ssh/rc"
  chown -R "$SUDO_USER:$SUDO_USER" "$USER_HOME/.ssh"
fi

echo "🎉 TSP NODES MOTD Installed Successfully!"
echo "➡ Reconnect via SSH to see the MOTD."
