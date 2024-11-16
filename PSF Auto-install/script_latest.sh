#!/bin/sh
sudo mkdir ./planetside;

cd ./planetside;
sudo apt-get -y install openjdk-8-jdk-headless;
sudo apt-get -y install scala;

sudo apt-get update;
sudo apt-get -y install apt-transport-https curl gnupg -yqq;
echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | sudo tee; /etc/apt/sources.list.d/sbt.list;
echo "deb https://repo.scala-sbt.org/scalasbt/debian /" | sudo tee /etc/apt/sources.list.d/sbt_old.list;
curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | sudo -H gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/scalasbt-release.gpg --import;
sudo chmod 644 /etc/apt/trusted.gpg.d/scalasbt-release.gpg;
sudo apt-get update;
sudo apt-get -y install sbt;

sudo sh -c 'echo "deb https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list';
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -;
sudo apt-get update;

## Pick which branch to comment out
## May 26th, 2020 branch
sudo apt-get -y install unzip;
# sudo apt-get -y install postgresql-10;
# sudo pg_ctlcluster 10 main start;
# sudo wget https://github.com/700hours/PSF-LoginServer/archive/838493e4bb2201580c7c2d3ab0776b9a175c3a3e.zip;
# unzip 838493e4bb2201580c7c2d3ab0776b9a175c3a3e.zip;
# sudo mv ./PSF-LoginServer-838493e4bb2201580c7c2d3ab0776b9a175c3a3e ./PSF-LoginServer;
## latest branch
sudo apt-get -y install postgresql-14;
git clone https://github.com/psforever/PSF-LoginServer.git;
cd ./PSF-LoginServer;
sudo wget https://github.com/psforever/PSCrypto/releases/download/v1.1/pscrypto-lib-1.1.zip;
unzip ./pscrypto-lib-1.1.zip;

sudo systemctl restart postgresql;
sudo runuser -c 'psql -c "CREATE DATABASE psforever;"' postgres;
sudo runuser -c 'psql -c "CREATE USER psforever;"' postgres;
sudo runuser -c "psql -c \"ALTER USER psforever WITH PASSWORD 'psforever';\"" postgres;
sudo runuser -c 'psql -c "ALTER DATABASE psforever OWNER TO psforever;"' postgres;

sudo ufw enable;
sudo ufw allow 51000;
sudo ufw allow 51001;
sudo ufw reload;

## For the May 2020 release
# printf "Make server IP address public\n";
# printf "// Copyright (c) 2017 PSForever\n" > ./PSF-LoginServer/pslogin/src/main/scala/LoginConfig.scala;
# printf "import java.net.InetAddress\n" >> ./PSF-LoginServer/pslogin/src/main/scala/LoginConfig.scala;
# printf "\n" >> ./PSF-LoginServer/pslogin/src/main/scala/LoginConfig.scala;
# printf "object LoginConfig {\n" >> ./PSF-LoginServer/pslogin/src/main/scala/LoginConfig.scala;
# printf "  var serverIpAddress : InetAddress = InetAddress.getByName(\"0.0.0.0\")\n" >> ./PSF-LoginServer/pslogin/src/main/scala/LoginConfig.scala;
# printf "}" >> ./PSF-LoginServer/pslogin/src/main/scala/LoginConfig.scala;

## Uncomment out to automatically compile
## Depending on which version being compiled, there are different commands
## For the May 26th, 2020 lscript:
# sudo sbt pslogin/run
## For the latest:
sudo nautilus;
sudo sbt server/compile;
sudo sbt server/run;