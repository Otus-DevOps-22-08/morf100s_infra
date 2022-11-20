#!/bin/bash

SSH_LOGIN=yc-user
SSH_HOST=158.160.43.108
SSH_PORT=22

SSH_CMD ()
{
	ssh $SSH_LOGIN@$SSH_HOST -p $SSH_PORT $1;
}

#SSH_CMD "mkdir -pv $TMP_BUILD_DIR/$BUILD_NUMBER_VAL"

SSH_CMD "sudo apt update"
SSH_CMD "sudo apt install -y ruby-full ruby-bundler build-essential git"
SSH_CMD "ruby -v"
SSH_CMD "bundler -v"
