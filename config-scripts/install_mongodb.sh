#!/bin/bash

SSH_LOGIN=yc-user
SSH_HOST=158.160.43.108
SSH_PORT=22

SSH_CMD ()
{
	ssh $SSH_LOGIN@$SSH_HOST -p $SSH_PORT $1;
}

SSH_CMD "wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | sudo apt-key add -"
SSH_CMD 'echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list'
SSH_CMD "sudo apt-get update"
SSH_CMD "sudo apt-get install -y mongodb-org"
SSH_CMD "sudo systemctl start mongod"
SSH_CMD "sudo systemctl enable mongod"
SSH_CMD "sudo systemctl status mongod"
