#!/usr/bin/env bash

# isponsorblocktv-install.sh
# Copyright (c) 2021-2025 community-scripts
# Author: connorjfarrell
# License: MIT
# Source: https://github.com/dmunozv04/iSponsorBlockTV

color() {
  YW="\033[33m"; GN="\033[1;92m"; CL="\033[m"; RD="\033[01;31m"
  BGN="\033[4;92m"
}
color
catch_errors() {
  set -Eeuo pipefail
  trap 'echo -e "${RD}Error occurred!${CL}"' ERR
}

catch_errors
echo -e "${GN}Beginning iSponsorBlockTV Alpine installation...${CL}\n"

# Update OS
echo -e "${YW}Updating Alpine packages...${CL}"
apk update && apk upgrade

# Installing Dependencies
echo -e "${YW}Installing dependencies...${CL}"
apk add --no-cache \
  python3 \
  py3-pip \
  git \
  curl
echo -e "${GN}Dependencies installed.${CL}\n"

# Clone the iSponsorBlockTV Repo
echo -e "${YW}Cloning iSponsorBlockTV repository...${CL}"
mkdir -p /opt
cd /opt
if [ ! -d "/opt/iSponsorBlockTV" ]; then
  git clone https://github.com/dmunozv04/iSponsorBlockTV.git
else
  echo -e "${RD}/opt/iSponsorBlockTV already exists, skipping clone.${CL}"
fi
cd /opt/iSponsorBlockTV

# Install Python Requirements
echo -e "${YW}Installing Python requirements...${CL}"
pip3 install --no-cache-dir -r requirements.txt
echo -e "${GN}Python dependencies installed.${CL}\n"

# save release tag for update script
GIT_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "main")
echo "$GIT_TAG" > /opt/iSponsorBlockTV_version.txt

# Create OpenRC Service
echo -e "${YW}Creating iSponsorBlockTV service...${CL}"
cat << 'EOF' > /etc/init.d/iSponsorBlockTV
#!/sbin/openrc-run

description="iSponsorBlockTV Service"
command="/usr/bin/python3"
command_args="/opt/iSponsorBlockTV/main.py"
directory="/opt/iSponsorBlockTV"
pidfile="/var/run/iSponsorBlockTV.pid"
command_background="true"

depend() {
    need net
    use dns logger
}
EOF

chmod +x /etc/init.d/iSponsorBlockTV
rc-update add iSponsorBlockTV default
echo -e "${GN}Service created and enabled at boot.${CL}\n"

# Start Service
echo -e "${YW}Starting iSponsorBlockTV service...${CL}"
rc-service iSponsorBlockTV start
echo -e "${GN}iSponsorBlockTV service started.${CL}\n"

# Cleanup
echo -e "${YW}Cleaning up...${CL}"
rm -rf /var/cache/apk/*
echo -e "${GN}Installation & cleanup complete.${CL}\n"

echo -e "${GN}iSponsorBlockTV has been successfully installed on Alpine!${CL}"
