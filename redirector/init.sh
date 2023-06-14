#!/bin/bash
sudo apt-get update -y; sudo apt-get install apache2 dos2unix -y
sudo a2enmod ssl rewrite proxy proxy_http
sudo rm /etc/apache2/sites-enabled/000-default.conf
sudo ln -s /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-enabled/
sudo sed -i '/SSLCertificateKeyFile/a \\t\tSSLProxyCheckPeerCN off' /etc/apache2/sites-enabled/default-ssl.conf
sudo sed -i '/SSLEngine on/a \\t\tSSLProxyEngine on' /etc/apache2/sites-enabled/default-ssl.conf
sudo sed -i '/<\/VirtualHost>/a <Directory \/var\/www\/html\/>\r\n\tOptions Indexes FollowSymLinks MultiViews\r\n\tAllowOverride All\r\n\tRequire all granted\r\n</Directory>' /etc/apache2/sites-enabled/default-ssl.conf
sudo dos2unix /etc/apache2/sites-enabled/default-ssl.conf
sudo systemctl restart apache2

sudo echo "Hello from Web Server" | sudo tee /var/www/html/index.html 
sudo echo -e 'RewriteEngine on\nRewriteCond %{REQUEST_URI} cooking [NC]\nRewriteRule .* https://localhost:8443%{REQUEST_URI} [P]\nRewriteCond %{REQUEST_URI} chaos [NC]\nRewriteRule .* https://localhost:8444%{REQUEST_URI} [P]\nRewriteCond %{REQUEST_URI} witch [NC]\nRewriteRule .* https://localhost:8445%{REQUEST_URI} [P]\nRewriteRule .* https://localhost:8446%{REQUEST_URI} [P]' > /tmp/temp
sudo mv /tmp/temp /var/www/html/.htaccess; sudo chown root:root /var/www/html/.htaccess; sudo chmod 644 /var/www/html/.htaccess
