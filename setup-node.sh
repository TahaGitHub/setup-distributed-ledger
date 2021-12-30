#!/bin/sh

DIR=`pwd`

sudo apt-get update

echo '\n'-------------------------------------------------------------------'\n'
echo "Installing needed libraries\n"
sudo apt-get install --yes net-tools wget unzip openssh-server gcc g++ make

echo '\n'-------------------------------------------------------------------'\n'
if [ ! -x "$(command -v docker)" ]; then
    echo "Installing Docker\n"
    sudo apt-get --yes install ca-certificates curl gnupg lsb-release 
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update
    sudo apt-get install --yes docker-ce docker-ce-cli containerd.io

    # Access docker withuot sudo
    sudo groupadd docker
    sudo gpasswd -a $USER docker
    sudo chmod 777 /var/run/docker.sock
else
    sudo groupadd docker
    sudo gpasswd -a $USER docker
    sudo chmod 777 /var/run/docker.sock
    echo "Docker found"
fi

echo '\n'-------------------------------------------------------------------'\n'
if [ "$(java -version 2>&1 | head -n 1 | cut -d\" -f 2)" \< 11 ]; then
    echo "Java version is less that 11 need to install 11 version"
    echo "Installing 11 JAVA..."
    sudo add-apt-repository --yes ppa:openjdk-r/ppa
    sudo apt-get update
    sudo apt install --yes openjdk-11-jdk
else
    echo "Java found && it's version equal or up to v11"
    java -version
fi

echo '\n'-------------------------------------------------------------------'\n'
if [ ! -x "$(command -v node)" ] || [ ! $(expr $(node -v) : ".*v16.*") -ne 0 ]; then
    echo "Node Js version is not found or less that 16 version"
    echo "Installing Node Js"
    curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
    sudo apt-get update
    sudo apt-get install --yes nodejs
else
    echo "Node Js found && it's version equal or up to v16"
    node --version
fi

echo '\n'-------------------------------------------------------------------'\n'
NODEDIR="$HOME/node"
if [ ! -d "$NODEDIR" ]; then
    echo "Create node folder in Home path\n"
    mkdir -m777 $NODEDIR
fi

FLUREEDIR="$NODEDIR/fluree/"
if [ ! -d "$FLUREEDIR" ]; then
    cd $NODEDIR
    if [ ! -e $NODEDIR/fluree-*.zip ]; then
        echo "Downloading fluree..."
        wget https://s3.amazonaws.com/fluree-releases-public/fluree-latest.zip
    fi

    echo "Unziping fluree..."
    mkdir -m777 $FLUREEDIR
    unzip fluree-*.zip -d $FLUREEDIR
    cd ..
else 
    echo "Fluree folder found in Home path"
fi

echo '\n'-------------------------------------------------------------------'\n'
echo "Pulling some docker image\n"
docker pull openwhisk/standalone:nightly

echo '\n'-------------------------------------------------------------------'\n'
APPDIR="$NODEDIR/distributed-ledger/"
if [ ! -d "$APPDIR" ]; then
    echo "Clone application github code\n"
    cd $NODEDIR
    git clone https://github.com/TahaGitHub/distributed-ledger.git
    cd $APPDIR
else 
    echo "Update application github code\n"
    cd $APPDIR
    git pull origin master
fi

# chown 777 -R $FLUREEDIR $APPDIR
# chown $(id -u):$(id -g) $FLUREEDIR $APPDIR

echo '\n'-------------------------------------------------------------------'\n'
echo "Install npm and running"
sudo npm install

echo '\n'-------------------------------------------------------------------'\n'
echo "There 3 type for node: main-master, master, worker\nNode type is $1"
echo '\n'-------------------------------------------------------------------'\n'
echo "Running..."
cd $DIR
./run-node.sh $1
