#!/bin/bash
sudo yum update -y
sudo yum install -y httpd
sudo chmod 777 /var/www/html -R
echo '<h1> Hello World </h1>' > /var/www/html/index.html
sudo systemctl start httpd
sudo systemctl enable httpd
