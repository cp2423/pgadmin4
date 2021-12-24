#!/usr/bin/env bash
sudo yum update
sudo amazon-linux-extras install docker
sudo service docker start
sudo usermod -a -G docker ec2-user
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
# create pgadmin container
docker pull dpage/pgadmin4
docker run -p 443:443 \
-v ~/pgadmin4/mnt:/var/lib/pgadmin \
-v ~/pgadmin4/cert.pem:/certs/server.cert \
-v ~/pgadmin4/key.pem:/certs/server.key \
-v ~/pgadmin4/servers.json:/pgadmin4/servers.json \
-e "PGADMIN_DEFAULT_EMAIL=postgres@db.com" \
-e "PGADMIN_DEFAULT_PASSWORD=multiverse" \
-e "PGADMIN_ENABLE_TLS=True" \
--name "pgadmin4" \
-d --restart always dpage/pgadmin4
