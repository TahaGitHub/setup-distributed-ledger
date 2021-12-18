#!/bin/sh

if [ $1 = 'pc' ]
then
# echo Hey $1.
apt update
apt install --yes software-properties-common
add-apt-repository --yes --update ppa:ansible/ansible
apt install --yes ansible

ansible-playbook install-docker-kubernetes.yaml -k -K

sudo usermod -aG docker $USER && newgrp docker
fi

[ $1 = 'reader' ]
then
echo Hey $1
fi

sudo kubeadm init --apiserver-advertise-address=192.168.1.70 --pod-network-cidr=192.168.0.0/16
sudo iptables -F && sudo iptables -t nat -F && sudo iptables -t mangle -F && sudo iptables -X

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
