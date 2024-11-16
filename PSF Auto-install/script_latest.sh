#!/bin/sh
printf "Headless PSF Login Server setup script\n";
sleep 3;

printf "creating directories\n";
sudo mkdir ./planetside;
cd ./planetside;

printf "getting jdk 8 and scala\n";
sudo apt-get -y install openjdk-8-jdk-headless;
sudo apt-get -y install scala;

printf "this section is dedicated to installing sbt\n";
sudo apt-get update;
sudo apt-get -y install apt-transport-https curl gnupg -yqq;
echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | sudo tee; /etc/apt/sources.list.d/sbt.list;
echo "deb https://repo.scala-sbt.org/scalasbt/debian /" | sudo tee /etc/apt/sources.list.d/sbt_old.list;
curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | sudo -H gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/scalasbt-release.gpg --import;
sudo chmod 644 /etc/apt/trusted.gpg.d/scalasbt-release.gpg;
sudo apt-get update;
sudo apt-get -y install sbt;

printf "acquiring apt  configuration files for installing postgresql 14\n";
sudo sh -c 'echo "deb https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list';
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -;
sudo apt-get update;

printf "postgres installation and the following PSF login server setup\n";
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

printf "Finishing the postgresql setup\n";
sudo systemctl restart postgresql;
sudo runuser -c 'psql -c "CREATE DATABASE psforever;"' postgres;
sudo runuser -c 'psql -c "CREATE USER psforever;"' postgres;
sudo runuser -c "psql -c \"ALTER USER psforever WITH PASSWORD 'psforever';\"" postgres;
sudo runuser -c 'psql -c "ALTER DATABASE psforever OWNER TO psforever;"' postgres;

printf "# Configuring server to be accessible by remote connections:\n" > README;
printf "# Change the line here from\n" >> README;
printf "# bind = 127.0.0.1\n" >> README;
printf "# to\n" >> README;
printf "# bind = 0.0.0.0\n" >> README;
printf "# It originally looks like this in the application.conf file:\n" >> README;
printf "# The socket bind address for all net.psforever.services except admin. 127.0.0.1 is the\n" >> README;
printf "# default for local testing, for public servers use 0.0.0.0 instead.\n" >> README;
printf "# bind = 127.0.0.1\n" >> README;
printf "\n" >> README;
printf "# Changing the name of the server in the in-game browser:\n" >> README;
printf "# On line 25 of application.conf is the server name\n" >> README;
printf "# Change 'PSForever' to ... anything\n" >> README;
printf "\n" >> README;
printf "# Setting the SQL username, password, and database:\n" >> README;
printf "# If you prefer to use a different identifier than 'psforever', starting on\n" >> README;
printf "# line 52 is the SQL settings. I chose 'parsely' as the example below.\n" >> README;
printf "\n" >> README;
printf "Example:\n" >> README;
printf "sudo find -type f -name application.conf\n" >> README;
printf "sudo nano [path]/application.conf\n" >> README;
printf "\n" >> README;

printf "how to set up GM:\n" >> README;
printf "create an account by logging in to server using Planetside account creation procedure\n" >> README;
printf "then use created account name\n" >> README;
printf 'psql -c "SELECT id FROM account WHERE username=[username];"\n' >> README;
printf 'psql -c "UPDATE account SET gm=true WHERE id=[id];"\n' >> README;
printf "\n" >> README;

printf "in the sbt command line, enter:\n" >> README;
printf "server/run\n" >> README;
printf "if manually starting" >> README;
printf "\n";

printf "Check README file in the local directory for information on making the PSF server public after it is done compiling. To run the server, either follow the README or use bash to run 'start_server.sh'.\n" >> README;
# printf "sudo sbt pslogin/run" > start_server.sh;
printf "sudo sbt server/run" > start_server.sh;
printf "\n";

printf "Allow port 51000\n";
sudo ufw enable;
sudo ufw allow 51000;
sudo ufw allow 51001;
sudo ufw reload;

set dt = $(date '+%m/%d/%Y');
printf "$dt \n" >> NOTICE;

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
printf "run a nautilus instance for ease of directory usage\n";
sudo nautilus;
sudo sbt server/compile;
printf "running the server post-compile\n";
sudo sbt server/run;
