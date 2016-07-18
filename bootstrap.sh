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
figlet -f standard Redis [1/8]
sudo apt-get install redis-server --assume-yes
sudo service redis-server restart
sleep 5
sudo redis-cli ping
#
# git
#
figlet -f standard Git [2/8]
sudo apt-get install git --assume-yes
#
# Node
#
figlet -f standard Node [3/8]
curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
sudo apt-get install -y nodejs --assume-yes
#
# nvm
#
cd ~
figlet -f standard NVM [4/8]
curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
export NVM_DIR="/home/vagrant/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
#
# graphicsmagick
#
figlet -f standard graphicsmagick [5/8]
sudo apt-get install graphicsmagick --assume-yes
#
# postgres
#
figlet -f standard postgres [6/8]

if [ -f /etc/init.d/postgresql ];
then
	sudo /etc/init.d/postgresql stop
	sudo apt-get -y remove --purge postgresql-9.1
	sudo apt-get -y remove --purge postgresql-9.2
	sudo apt-get -y remove --purge postgresql-9.3
	sudo apt-get -y remove --purge postgresql-9.4
	sudo apt-get -y autoremove
fi
sudo apt-key adv --keyserver keys.gnupg.net --recv-keys 7FCC7D46ACCC4CF8
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main 9.5" >> /etc/apt/sources.list.d/postgresql.list'
sudo apt-get update
sudo apt-get -y install postgresql-9.5
sudo sh -c 'echo "local all postgres trust" > /etc/postgresql/9.5/main/pg_hba.conf'
sudo sh -c 'echo -n "host all all 127.0.0.1/32 trust" >> /etc/postgresql/9.5/main/pg_hba.conf'
sudo /etc/init.d/postgresql restart
#
# Get repos
#
cd ~
mkdir ff
cd ff
#
# FF Server
#
figlet -f standard FF Server [7/8]
git clone -b stable https://github.com/FreeFeed/freefeed-server 
cd freefeed-server
nvm install
npm install
#
# Tweaking configuation (!!!! This should be changed in Git)
#
sed -i 's/http\:\/\/localhost\:3333/http:\/\/localhost\:5783/g' config/environments/development.js
sed -i "s/logLevel\: 'warn'/logLevel\: 'info'/g" config/environments/development.js
#
# Create the database
#
psql -c 'create database freefeed;' -U postgres
psql -c 'create database freefeed_test;' -U postgres
sudo -u postgres bash -c "psql -c \"CREATE USER freefeed WITH PASSWORD 'freefeed';\""
psql -c 'alter user freefeed with superuser;' -U postgres
cp knexfile.js{.dist,}
./node_modules/.bin/knex migrate:latest
./node_modules/.bin/knex migrate:latest --env test
#
# Create folders
#
mkdir ./public/files/attachments/thumbnails/
mkdir ./public/files/attachments/thumbnails2/
mkdir /tmp/pepyatka-media/
mkdir /tmp/pepyatka-media/attachments/
mkdir /tmp/pepyatka-media/attachments/thumbnails/
mkdir /tmp/pepyatka-media/attachments/thumbnails2/
mkdir /tmp/pepyatka-media/attachments/anotherTestSize/
#
# FF Frontend
#
figlet -f standard FF Frontend [8/8]
cd ~/ff
git clone -b stable https://github.com/FreeFeed/freefeed-react-client 
cd freefeed-react-client
npm install
make dev

cat << EOF


FreeFeed devevlopment environment provisioning has been completed.

Launching FreeFeed server:
  cd ~/ff/freefeed-server
  nvm use
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
