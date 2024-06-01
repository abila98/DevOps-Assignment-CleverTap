#!/bin/bash
sudo apt install awscli -y

#!/bin/bash
exec > /var/log/user-data.log 2>&1
set -e

# Get RDS credentials from SSM Parameter Store
DB_ENDPOINT=$(aws ssm get-parameter --name /wordpress/db_endpoint --region us-west-1 --query "Parameter.Value" --output text)
DB_USERNAME=$(aws ssm get-parameter --name /wordpress/db_username --region us-west-1 --query "Parameter.Value" --output text)
DB_PASSWORD=$(aws ssm get-parameter --name /wordpress/db_password --region us-west-1 --query "Parameter.Value" --output text)

echo "DB_ENDPOINT: $DB_ENDPOINT"
echo "DB_USERNAME: $DB_USERNAME"
echo "DB_PASSWORD: $DB_PASSWORD"


# Update wp-config.php with the fetched credentials
sudo sed -i "s/define( 'DB_NAME', '.*' );/define( 'DB_NAME', 'mydatabase' );/" /var/www/html/wp-config.php
sudo sed -i "s/define( 'DB_HOST', '.*' );/define( 'DB_HOST', '$DB_ENDPOINT' );/" /var/www/html/wp-config.php
sudo sed -i "s/define( 'DB_USER', '.*' );/define( 'DB_USER', '$DB_USERNAME' );/" /var/www/html/wp-config.php
sudo sed -i "s/define( 'DB_PASSWORD', '.*' );/define( 'DB_PASSWORD', '$DB_PASSWORD' );/" /var/www/html/wp-config.php


sudo systemctl restart apache2

