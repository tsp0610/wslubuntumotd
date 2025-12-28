#!/bin/bash

# ===========================================
# Secure SSH Setup + Custom MOTD - TSP NODES
# WSL + VPS Compatible
# ===========================================

clear

echo -e "\033[1;36m🔐 TSP NODES - Secure SSH Configuration\033[0m"
echo -e "\033[1;37m--------------------------------------\033[0m"

sleep 1

echo -e "\033[1;34m▶ Updating SSH settings...\033[0m"

sudo bash -c 'cat <<EOF > /etc/ssh/sshd_config
# SSH LOGIN SETTINGS
PasswordAuthentication yes
PermitRootLogin yes
PubkeyAuthentication no
ChallengeResponseAuthentication no
UsePAM yes

# SECURITY
X11Forwarding no
AllowTcpForwarding yes
PrintMotd no

# SFTP
Subsystem sftp /usr/lib/openssh/sftp-server
EOF'

echo -e "\033[1;32m✔ SSH configuration applied!\033[0m"

echo -e "\033[1;34m▶ Restarting SSH...\033[0m"
sudo systemctl restart ssh 2>/dev/null || sudo service ssh restart
echo -e "\033[1;32m✔ SSH restarted!\033[0m"

# ------------------------------------------------
# Install MOTD (VPS-style)
# ------------------------------------------------
echo -e "\033[1;34m▶ Installing Custom MOTD...\033[0m"
bash <(curl -fsSL https://raw.githubusercontent.com/tsp0610/vps-motd/main/motd.sh)
echo -e "\033[1;32m✔ MOTD installed!\033[0m"

# ------------------------------------------------
# WSL DETECTION & FIX
# ------------------------------------------------
if grep -qi microsoft /proc/version; then
  echo -e "\033[1;33m⚠ WSL detected — applying MOTD fix...\033[0m"

  mkdir -p /home/$SUDO_USER/.ssh

  cat <<'EOF' > /home/$SUDO_USER/.ssh/rc
#!/bin/bash
if [ -x /usr/bin/run-parts ]; then
  run-parts /etc/update-motd.d
fi
EOF

  chmod 700 /home/$SUDO_USER/.ssh
  chmod 600 /home/$SUDO_USER/.ssh/rc
  chown -R $SUDO_USER:$SUDO_USER /home/$SUDO_USER/.ssh

  echo -e "\033[1;32m✔ WSL MOTD hook installed!\033[0m"
fi

# ------------------------------------------------
# FINAL MESSAGE
# ------------------------------------------------
clear

cat << "EOF"

████████╗███████╗██████╗     ███╗   ██╗ ██████╗ ██████╗ ███████╗███████╗
╚══██╔══╝██╔════╝██╔══██╗    ████╗  ██║██╔═══██╗██╔══██╗██╔════╝██╔════╝
   ██║   ███████╗██████╔╝    ██╔██╗ ██║██║   ██║██║  ██║█████╗  ███████╗
   ██║   ╚════██║██╔═══╝     ██║╚██╗██║██║   ██║██║  ██║██╔══╝  ╚════██║
   ██║   ███████║██║         ██║ ╚████║╚██████╔╝██████╔╝███████╗███████║
   ╚═╝   ╚══════╝╚═╝         ╚═╝  ╚═══╝ ╚═════╝ ╚═════╝ ╚══════╝╚══════╝

EOF

echo -e "\033[1;32m🎉 SSH + MOTD setup completed successfully!\033[0m"
echo -e "\033[1;36m✨ TSP NODES — Ready to go 🚀\033[0m"
