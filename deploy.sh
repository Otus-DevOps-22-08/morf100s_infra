#!/bin/bash

SSH_LOGIN=yc-user
SSH_HOST=158.160.43.108
SSH_PORT=22

SSH_CMD ()
{
	ssh $SSH_LOGIN@$SSH_HOST -p $SSH_PORT $1;
}

SSH_CMD "git clone -b monolith https://github.com/express42/reddit.git"
SSH_CMD "cd reddit && bundle install"
SSH_CMD 'cd reddit && puma -d'
SSH_CMD 'ps aux | grep puma'
