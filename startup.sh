#!/bin/bash
# Install Apache, PHP, MySQL, and WordPress on Debian
sudo apt-get update
sudo apt-get install -y apache2 mysql-server php php-mysql libapache2-mod-php wget unzip
sudo systemctl enable apache2
sudo systemctl enable mysql

# Secure MySQL and set root password
db_root_pw=$(openssl rand -base64 16)
echo "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$db_root_pw'; FLUSH PRIVILEGES;" | sudo mysql

echo $db_root_pw > /root/mysql_root_pw.txt

# Download and configure WordPress
wget https://wordpress.org/latest.zip
unzip latest.zip
sudo mv wordpress/* /var/www/html/
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/

# Create WordPress database and user
wp_db=wordpress
wp_user=wpuser
wp_pw=$(openssl rand -base64 16)
echo "CREATE DATABASE $wp_db; CREATE USER '$wp_user'@'localhost' IDENTIFIED BY '$wp_pw'; GRANT ALL PRIVILEGES ON $wp_db.* TO '$wp_user'@'localhost'; FLUSH PRIVILEGES;" | sudo mysql -u root -p$db_root_pw

echo $wp_pw > /root/wp_db_pw.txt

# Configure wp-config.php
template=/var/www/html/wp-config-sample.php
config=/var/www/html/wp-config.php
sudo cp $template $config
sudo sed -i "s/database_name_here/$wp_db/" $config
sudo sed -i "s/username_here/$wp_user/" $config
sudo sed -i "s/password_here/$wp_pw/" $config

# Restart Apache
sudo systemctl restart apache2
