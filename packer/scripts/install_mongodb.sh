#!/bin/sh

wget -qO - https://www.mongodb.org/static/pgp/server-3.2.asc | sudo apt-key add -
echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
apt-get update
sudo apt-get update
sleep 15
sudo apt install -y mongodb-org
sudo sed '/bindIp/d' -i /etc/mongod.conf
sudo systemctl start mongod
sudo systemctl enable mongod
