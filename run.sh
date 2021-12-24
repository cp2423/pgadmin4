#!/usr/bin/env bash
REPO="https://github.com/cp2423/pgadmin4/"
sudo yum update -y
sudo amazon-linux-extras install -y docker
sudo service docker start
#sudo usermod -a -G docker ec2-user
sudo chkconfig docker on
# folder to keep everything in
mkdir pgadmin4
cd pgadmin4
# create self-signed SSL certificate
#ip = `curl https://api.ipify.org`
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -sha256 -days 365 -nodes \
-subj "/C=US/ST=Oregon/L=Portland/O=Company Name/OU=Org/CN=."
# create volume to mount in container with config files
mkdir mnt
wget $REPO"blob/main/mnt/pgadmin4.db?raw=true" -o mnt/pgadmin4.db
sudo chown -R 5050:5050 mnt/
# create pre-populated list of servers
wget $REPO"blob/main/servers.json?raw=true" -o servers.json
sudo chown -R 5050:5050 servers.json
# run pgadmin container
docker pull dpage/pgadmin4
sudo docker run -p 443:443 \
-v ~/pgadmin4/mnt:/var/lib/pgadmin \
-v ~/pgadmin4/cert.pem:/certs/server.cert \
-v ~/pgadmin4/key.pem:/certs/server.key \
-v ~/pgadmin4/servers.json:/pgadmin4/servers.json \
-e "PGADMIN_DEFAULT_EMAIL=postgres@db.com" \
-e "PGADMIN_DEFAULT_PASSWORD=multiverse" \
-e "PGADMIN_ENABLE_TLS=True" \
--name "pgadmin4" \
-d --restart always dpage/pgadmin4
# run postgres container
docker pull postgres
sudo docker run --name postgres -e POSTGRES_PASSWORD=multiverse -d postgres
# done!
ip=`curl https://api.ipify.org`
echo "Go to https://$ip/ to log in to pgadmin with username = postgres@db.com and password = multiverse"
