# FastView

**FastView** is an ultra-lightweight, high-performance web interface for browsing your remote server. While other file managers are heavy and bloated, FastView is built for speed and simplicity—allowing you to instantly open, search, and preview files via your browser with a sleek, VS-Code-inspired interface.

## Features
- VS Code inspired UI (Sidebar explorer, file tabs, code highlighting).
- Supports Python, Markdown, JSON, HTML, and more.
- Built-in PDF and Image preview.
- Directory navigation with Nginx JSON autoindex.
- Basic Authentication support.

## Prerequisites
This project is designed for Linux servers (Ubuntu/Debian recommended). You will need:
- **Nginx**: Web server to serve files.
- **apache2-utils**: Required for the `htpasswd` command.
- **Certbot**: For SSL/HTTPS support.

To install them manually:
```bash
sudo apt update
sudo apt install nginx apache2-utils certbot python3-certbot-nginx
```

## Quick Deployment
1. Download or clone this repository to your server.
2. Run the provided installation script:
   ```bash
   sudo chmod +x install.sh
   sudo ./install.sh
   ```
3. Follow the prompts to enter your domain, file paths, and authentication credentials.
4. Once completed, the script will suggest running Certbot for SSL.

## Manual Configuration
If you prefer to configure Nginx manually:
1. Use `nginx_https.example` as a template for your site configuration.
2. Update the `YOUR_DOMAIN`, `/ABSOLUTE/PATH/TO/YOUR/FILES/`, and `/ABSOLUTE/PATH/TO/PROJECT/` placeholders.
3. Create your `.htpasswd` file:
   ```bash
   sudo htpasswd -c /etc/nginx/.htpasswd your_username
   ```

## Customization
### Favicon
You can update the website icon by replacing `favicon.png` in the project directory with your own image. Ensure the filename remains `favicon.png`.

### File Types
The viewer uses Prism.js for syntax highlighting. You can modify the `types` block in the Nginx config to add or change how different file extensions are served.

## Troubleshooting
- Ensure the `alias` paths in your Nginx configuration are absolute and accessible by the `www-data` user.
- If directory listing fails, check that `autoindex_format json;` is correctly set in your Nginx configuration.
