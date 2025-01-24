#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/connorjfarrell/ProxmoxVE/refs/heads/isponsorblocktv/misc/build.func)
# Copyright (c) 2021-2025 community-scripts
# Author: connorjfarrell
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/dmunozv04/iSponsorBlockTV

APP="iSponsorBlockTV"
var_tags="adblock;sponsor"
var_cpu="1"
var_ram="512"
var_disk="8"
var_os="alpine"
var_version="3.20"
var_unprivileged="1"

header_info "$APP"
base_settings

variables
color
catch_errors

function update_script() {
    header_info
    check_container_storage
    check_container_resources

    if [[ ! -f /opt/${APP}/main.py ]]; then
        msg_error "No ${APP} Installation Found!"
        exit
    fi

    # get newest release from git
    RELEASE=$(curl -fsSL "https://api.github.com/repos/dmunozv04/iSponsorBlockTV/releases/latest" | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')
    if [[ "${RELEASE}" != "$(cat /opt/${APP}_version.txt)" ]] || [[ ! -f /opt/${APP}_version.txt ]]; then
        msg_info "Updating $APP"

        # Stop service
        msg_info "Stopping $APP"
        rc-service iSponsorBlockTV stop
        msg_ok "Stopped $APP"

        # Backup
        msg_info "Creating Backup"
        tar -czf "/opt/${APP}_backup_$(date +%F).tar.gz" /opt/${APP}
        msg_ok "Backup Created"

        # Pull latest changes
        msg_info "Pulling latest code v${RELEASE}"
        cd /opt/${APP} || exit
        git fetch --all
        git checkout "tags/${RELEASE}" || git checkout main
        pip3 install -r requirements.txt
        msg_ok "Code Updated"

        # Start service
        msg_info "Starting $APP"
        rc-service iSponsorBlockTV start
        msg_ok "Started $APP"

        echo "${RELEASE}" > /opt/${APP}_version.txt
        msg_ok "Update Successful"
    else
        msg_ok "No update required. ${APP} is already at v${RELEASE}"
    fi
    exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access and configure your container as needed.${CL}"
