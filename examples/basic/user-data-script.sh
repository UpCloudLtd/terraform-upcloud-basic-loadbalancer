#!/bin/bash

# Install HTTP server and firewall
apt update
apt install -y apache2 ufw

# Add hostname to HTTP response to identify back-end server
echo "Hello from $(hostname)" > /var/www/html/index.html

# Allow incoming traffic only from private network
ufw enable
ufw allow in on eth2
