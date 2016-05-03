#!/usr/bin/env bash
#
# This script provisions FreeFeed development environment
#
set -o errexit
echo Provisioning FreeFeed development environment
sudo apt-get update
sudo apt-get install figlet --assume-yes
figlet -f standard FreeFeed
sudo apt-get install build-essential libssl-dev --assume-yes
#
# redis
#
figlet -f standard Redis [1/7]
sudo apt-get install tcl8.5 --assume-yes
wget http://download.redis.io/releases/redis-stable.tar.gz
tar xzf redis-stable.tar.gz
cd redis-stable
make
make test
sudo make install
cd utils
echo -n | sudo ./install_server.sh
cd ~
#
# git
#
figlet -f standard Git [2/7]
sudo apt-get install git --assume-yes
#
# Node
#
figlet -f standard Node [3/7]
curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
sudo apt-get install -y nodejs --assume-yes
#
# nvm
#
figlet -f standard NVM [4/7]
curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
export NVM_DIR="/home/vagrant/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
#
# graphicsmagick
#
figlet -f standard graphicsmagick [5/7]
sudo apt-get install graphicsmagick --assume-yes
#
# Get repos
#
cd ~
mkdir ff
cd ff
#
# FF Server
#
figlet -f standard FF Server [6/7]
git clone -b stable https://github.com/FreeFeed/freefeed-server 
cd freefeed-server
nvm install
npm install
npm test
#
# Tweaking configuation (!!!! This should be changed in Git)
#
sed -i 's/http\:\/\/localhost\:3333/http:\/\/localhost\:5783/g' config/environments/development.js
sed -i "s/logLevel\: 'warn'/logLevel\: 'info'/g" config/environments/development.js
#
# FF Frontend
#
figlet -f standard FF Frontend [7/7]
cd ~/ff
git clone -b stable https://github.com/FreeFeed/freefeed-react-client 
cd freefeed-react-client
npm install
make dev
npm test

cat << EOF


FreeFeed dev. environment provisioning has been completed.

Please reboot the box (vagrant ssh, sudo reboot) before starting the sever,
so that redis could start.

Launching FreeFeed server:
  cd ~/ff/freefeed-server
  npm start

Launching FreeFeed frontend:
  cd ~/ff/freefeed-react-client
  ./dev-server

Default frontend URL: http://localhost:5783

To create a test user via API:
curl -v -d "username=test" -d "password=test" http://localhost:3000/v1/users

Happy hacking!

FF Team, https://dev.freefeed.net/

EOF
