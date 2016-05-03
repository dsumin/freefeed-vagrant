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
sudo apt-get install redis-server --assume-yes
sudo service redis-server stop
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
cd ~
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
sudo service redis-server start
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


FreeFeed devevlopment environment provisioning has been completed.

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
