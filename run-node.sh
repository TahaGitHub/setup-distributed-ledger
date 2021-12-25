#!/bin/sh

sudo groupadd docker
sudo gpasswd -a $USER docker
sudo chmod 777 /var/run/docker.sock

cd $HOME/node/distributed-ledger
npm start --TYPE=$1
