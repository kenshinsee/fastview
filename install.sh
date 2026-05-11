#!/bin/bash

# FastView - Deployment Script

set -e

# --- Helper Functions ---
echo_info() { echo -e "\033[0;34m[INFO]\033[0m $1"; }
echo_success() { echo -e "\033[0;32m[SUCCESS]\033[0m $1"; }
echo_error() { echo -e "\033[0;31m[ERROR]\033[0m $1"; }

# --- Check Prerequisites ---
if [[ $EUID -ne 0 ]]; then
   echo_error "This script must be run as root (use sudo)"
   exit 1
fi

# --- Install Packages ---
echo_info "Checking and installing dependencies..."
apt update
apt install -y nginx apache2-utils certbot python3-certbot-nginx

# --- Get User Configuration ---
echo ""
echo "--- Configuration ---"
read -p "Enter your domain name (e.g., files.example.com): " DOMAIN
read -p "Enter the ABSOLUTE path to the directory you want to view: " FILES_PATH
read -p "Enter the ABSOLUTE path to this project directory: " PROJECT_PATH
read -p "Enter a username for Basic Auth: " AUTH_USER
read -s -p "Enter a password for Basic Auth: " AUTH_PASS
echo ""

# Ensure paths have trailing slashes where needed
[[ "${FILES_PATH}" != */ ]] && FILES_PATH="${FILES_PATH}/"
[[ "${PROJECT_PATH}" != */ ]] && PROJECT_PATH="${PROJECT_PATH}/"

# --- Generate .htpasswd ---
echo_info "Setting up Basic Authentication..."
htpasswd -bc /etc/nginx/.htpasswd "$AUTH_USER" "$AUTH_PASS"
echo_success "Auth file created at /etc/nginx/.htpasswd"

# --- Generate Nginx Config ---
echo_info "Generating Nginx configuration..."
NGINX_CONF="/etc/nginx/sites-available/${DOMAIN}"

cat > "$NGINX_CONF" <<EOF
server {
    server_name ${DOMAIN};

    listen 80;

    location /my-files/ {
        alias ${FILES_PATH};
        autoindex on;
        autoindex_format json;
        auth_basic "Restricted Area";
        auth_basic_user_file /etc/nginx/.htpasswd;
        autoindex_exact_size off;
        charset utf-8;
        source_charset utf-8;
        override_charset on;
        types {
            text/html   html;
            text/plain  txt py md log;
            application/json  json;
        }
        add_header 'Access-Control-Allow-Origin' '*';
    }

    location = /favicon.png {
        alias ${PROJECT_PATH}favicon.png;
    }

    location /view {
        alias ${PROJECT_PATH}viewer.html;
        default_type text/html;
        auth_basic "Restricted Area";
        auth_basic_user_file /etc/nginx/.htpasswd;
    }

    location / {
        return 301 /view;
    }
}
EOF

# Enable the site
ln -sf "$NGINX_CONF" "/etc/nginx/sites-enabled/"
rm -f /etc/nginx/sites-enabled/default

# Test and restart Nginx
nginx -t
systemctl restart nginx
echo_success "Nginx configured and restarted."

# --- SSL Setup Suggestion ---
echo ""
echo "--- SSL Setup ---"
echo "To enable HTTPS, please run the following command:"
echo "  sudo certbot --nginx -d ${DOMAIN}"
echo ""
echo_success "Deployment complete! Visit http://${DOMAIN}/view to see your files."
