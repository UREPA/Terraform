#!/bin/bash
# Log all output for debugging
exec > /var/log/startup-script.log 2>&1
set -x

# Wait for cloud-init to finish (if present)
if command -v cloud-init >/dev/null 2>&1; then
  while [ ! -f /var/lib/cloud/instance/boot-finished ]; do
    sleep 1
  done
fi

# Update package list and install Apache, MariaDB (MySQL), PHP, and required tools
sudo apt-get update -y
sudo apt-get install -y apache2 mariadb-server php php-mysql libapache2-mod-php wget unzip

# Enable and start Apache and MariaDB
sudo systemctl enable apache2
sudo systemctl start apache2
sudo systemctl enable mariadb
sudo systemctl start mariadb

# Create WordPress database and user (as root, no password)
wp_db=wordpress
wp_user=wpuser
wp_pw=$(openssl rand -base64 16)
echo "CREATE DATABASE IF NOT EXISTS $wp_db; CREATE USER IF NOT EXISTS '$wp_user'@'localhost' IDENTIFIED BY '$wp_pw'; GRANT ALL PRIVILEGES ON $wp_db.* TO '$wp_user'@'localhost'; FLUSH PRIVILEGES;" | sudo mariadb

echo $wp_pw > /root/wp_db_pw.txt

# Download and configure WordPress
wget https://wordpress.org/latest.zip
unzip latest.zip
sudo mv wordpress/* /var/www/html/
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/

# Configure wp-config.php
template=/var/www/html/wp-config-sample.php
config=/var/www/html/wp-config.php
sudo cp $template $config
sudo sed -i "s/database_name_here/$wp_db/" $config
sudo sed -i "s/username_here/$wp_user/" $config
sudo sed -i "s/password_here/$wp_pw/" $config

# Ensure required PHP modules are installed
apt-get install -y php-mysql php-gd php-xml php-mbstring php-curl php-zip

# Enable Apache mod_rewrite for WordPress permalinks and wp-admin
sudo a2enmod rewrite

# Set correct permissions and ownership for WordPress files
touch /var/log/wp-perms.log
chown -R www-data:www-data /var/www/html >> /var/log/wp-perms.log 2>&1
find /var/www/html -type d -exec chmod 755 {} \; >> /var/log/wp-perms.log 2>&1
find /var/www/html -type f -exec chmod 644 {} \; >> /var/log/wp-perms.log 2>&1

# Create a default .htaccess if missing
if [ ! -f /var/www/html/.htaccess ]; then
  cat <<EOT > /var/www/html/.htaccess
# BEGIN WordPress
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>
# END WordPress
EOT
  chown www-data:www-data /var/www/html/.htaccess
  chmod 644 /var/www/html/.htaccess
fi

# Log Apache configtest and status for troubleshooting
apache2ctl configtest > /var/log/apache2/configtest.log 2>&1
systemctl status apache2 > /var/log/apache2/status.log 2>&1

# Restart Apache to apply changes
systemctl restart apache2
