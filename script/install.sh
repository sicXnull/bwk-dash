#!/bin/bash

#Variables - START
TARBALLURL="https://github.com/sicXnull/POSQ/releases/download/2.1.3/posq-2.1.3-linux64.tar.gz"
TARBALLNAME="posq-2.1.3-linux64.tar.gz"
BOOTSTRAPURL="https://github.com/sicXnull/POSQ/releases/download/2.1.3/bootstrap.dat.zip"
BOOTSTRAPARCHIVE="bootstrap.dat.zip"
POSQVERSION="2.1.3"
# POSQ-Dash variables.
DASH_BIN_TAR="posq-dash-1.0.0-linux-amd64.tar.gz"
DASH_HTML_TAR="posq-dash-1.0.0-html.tar.gz"
DASH_PORT="8080"
DASH_VER="v1.0.0"
#Variables - END

#TODO: Combine back with SHN install script.
sudo apt-get install -y gcc unzip
sudo adduser posq

#POSQ Service - START
sudo cat > /etc/systemd/system/posqd.service << EOL
[Unit]
Description=POSQs's distributed currency daemon
After=network.target
[Service]
User=posq
Group=posq
WorkingDirectory=/home/posq
Type=forking
ExecStart=/usr/local/bin/posqd -datadir=/home/posq/.posq -conf=/home/posq/.posq/posq.conf -daemon
ExecStop=/usr/local/bin/posq-cli -datadir=/home/posq/.posq -conf=/home/posq/.posq/posq.conf stop
#KillMode=process
Restart=always
TimeoutSec=120
RestartSec=30
[Install]
WantedBy=multi-user.target
EOL
sleep 1
#POSQ Service - END

#POSQ Config - START
sudo mkdir /home/posq/.posq
sudo touch /home/posq/.posq/posq.conf
sudo chown -R posq:posq /home/posq/.posq
RPCUSER=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1)
RPCPASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
sudo cat > /home/posq/.posq/posq.conf << EOL
rpcuser=${RPCUSER}
rpcpassword=${RPCPASSWORD}
daemon=1
EOL
#POSQ Config - END

#POSQ-Dash Setup - START
# Setup systemd service and start.
sudo cat > /etc/systemd/system/posq-dash.service << EOL
[Unit]
Description=POSQ Home Node Dashboard
After=network.target
[Service]
User=posq
Group=posq
WorkingDirectory=/home/posq/dash
ExecStart=/usr/local/bin/posq-dash
Restart=always
TimeoutSec=10
RestartSec=35
[Install]
WantedBy=multi-user.target
EOL
sleep 1
# Get binaries and install.
wget https://github.com/Poseidon-POSQ/posq-dash/releases/download/$DASH_VER/$DASH_BIN_TAR
sudo tar -zxf $DASH_BIN_TAR -C /usr/local/bin
rm -f $DASH_BIN_TAR
# Copy the html files to the dash folder and create.
wget https://github.com/Poseidon-POSQ/posq-dash/releases/download/$DASH_VER/$DASH_HTML_TAR
sudo mkdir -p /home/posq/dash
sudo tar -zxf $DASH_HTML_TAR -C /home/posq/dash
rm -f $DASH_HTML_TAR
# Create .env file for dashboard api and cron.
cat > /home/posq/dash/.env << EOL
DASH_DONATION_ADDRESS=TESTADDRESSHERE
DASH_PORT=${DASH_PORT}
DASH_RPC_ADDR=localhost
DASH_RPC_PORT=5511
DASH_RPC_USER=${RPCUSER}
DASH_RPC_PASS=${RPCPASSWORD}
DASH_WEBSITE=/home/posq/dash
DASH_DB=/home/posq/dash/posq-dash.db
DASH_TOR=
EOL
sleep 1
# Cleanup/enforce ownership.
sudo chown -R posq:posq /home/posq/dash
# Setup timer and service for posq-cron.
sudo cat > /etc/systemd/system/posq-cron.service << EOL
[Unit]
Description=POSQ Home Node Dashboard - Cron
After=network.target
[Service]
User=posq
Group=posq
WorkingDirectory=/home/posq/dash
ExecStart=/usr/local/bin/posq-cron
Restart=always
TimeoutSec=10
RestartSec=35
EOL
sleep 1
sudo cat > /etc/systemd/system/posq-cron.timer << EOL
[Unit]
Description=POSQ Home Node Dashboard - Cron
[Timer]
OnCalendar=*-*-* *:*:00
OnBootSec=35
OnUnitActiveSec=60
[Install]
WantedBy=timers.target
EOL
sleep 1
# Enable service and timer.
sudo systemctl enable posq-cron.timer
sudo systemctl enable posq-dash.service
#POSQ-Dash Setup - END

#POSQ Node - START
sudo wget $TARBALLURL
sleep 2
sudo tar -xzf $TARBALLNAME -C /usr/local
sudo rm $TARBALLNAME
sleep 3
cd ~
sudo chown -R posq:posq /home/posq/posq/
sleep 1
sudo systemctl enable posqd.service
sleep 1
#POSQ Node - END

sudo reboot
