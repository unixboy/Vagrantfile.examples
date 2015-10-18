#!/usr/bin/env bash

#mostly from https://github.com/fideloper/Vaprobash

#basics
echo ">>>>>>>>>> Install basics <<<<<<<<<<"
sudo apt-get update
sudo apt-get install -y git-core curl python-software-properties sqlite3

echo ">>>>>>>>>> Add third party repos <<<<<<<<<<"
sudo add-apt-repository -y ppa:ondrej/php5
sudo add-apt-repository -y ppa:ondrej/apache2
sudo add-apt-repository -y ppa:chris-lea/node.js
sudo add-apt-repository -y ppa:fish-shell/release-2
sudo add-apt-repository -y ppa:webupd8team/java
sudo apt-get update

#fish shell
echo ">>>>>>>>>> Install fish shell <<<<<<<<<<"
sudo apt-get install -y fish
chsh -s $(which fish) vagrant
rm -rf /home/vagrant/.config/fish
git clone https://github.com/flammel/fish-config.git /home/vagrant/.config/fish

#java
echo ">>>>>>>>>> Install java <<<<<<<<<<"
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
sudo apt-get -y install oracle-java8-installer

#leiningen
echo ">>>>>>>>>> Download leiningen <<<<<<<<<<"
mkdir -p /home/vagrant/bin
curl -o /home/vagrant/bin/lein https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein
chmod a+x /home/vagrant/bin/lein

#nodejs
echo ">>>>>>>>>> Install nodejs <<<<<<<<<<"
sudo apt-get install -y nodejs

#php
echo ">>>>>>>>>> Install php <<<<<<<<<<"
sudo apt-get install -y php5-cli php5-sqlite php5-curl php5-mcrypt php5-imagick php5-intl php5-sqlite php5-gd

#apache
echo ">>>>>>>>>> Install apache <<<<<<<<<<"
sudo apt-get install -y libapache2-mod-php5

echo ">>>>>>>>>> Configure Apache <<<<<<<<<<"
sudo echo 'ServerName localhost' >> /etc/apache2/apache2.conf
sudo a2enmod rewrite
sudo service apache2 restart
if [ ! -d /vagrant/apache_log ]; then
	mkdir -p /vagrant/apache_log
fi
VHOST=$(cat <<EOF
<VirtualHost *:80>
	DocumentRoot /vagrant/$1/public
	ErrorLog /vagrant/apache_log/error.log
	CustomLog /vagrant/apache_log/access.log combined

	<Directory /vagrant/$1/public>
		Options -Indexes +FollowSymLinks +MultiViews
		AllowOverride All
		Require all granted
	</Directory>
</VirtualHost>
EOF
)
echo "${VHOST}" > /etc/apache2/sites-enabled/000-default.conf

#composer
composer -v > /dev/null 2>&1
COMPOSER_IS_INSTALLED=$?
if [[ $COMPOSER_IS_INSTALLED -ne 0 ]]; then
	echo ">>>>>>>>>> Install composer <<<<<<<<<<"
	curl -sS https://getcomposer.org/installer | php
	sudo mv composer.phar /usr/local/bin/composer
else
	echo ">>>>>>>>>> Update composer <<<<<<<<<<"
	sudo composer self-update
fi

#project
public_folder="/vagrant/$1/public"
if [ ! -d $public_folder ]; then
	mkdir -p $public_folder
fi

#create git repo
git init
