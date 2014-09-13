
log "generating ssl certs"
/opt/local/etc/nginx/sslgen.sh

log "enabling http services"
svcadm enable nginx
svcadm enable php-fpm
svcadm enable memcached

log "enabling freeswitch"
svcadm enable freeswitch

log "Creating FusionPBX DB"

FUS_PW=$(od -An -N4 -x /dev/random | head -1 | tr -d ' ');

echo "CREATE USER fusionpbxadmin WITH PASSWORD '$FUS_PW';" >> /tmp/fus.sql
echo "CREATE DATABASE fusionpbx;" >> /tmp/fus.sql
echo "GRANT ALL PRIVILEGES ON DATABASE fusionpbx to fusionpbxadmin;" >> /tmp/fus.sql

log "Injecting FusionPBX SQL"
sudo PGPASSWORD="postgres" -u postgres /opt/local/bin/psql -w -U postgres < /tmp/fus.sql

log "determine the webui address for the motd"

WEBUI_ADDRESS=$PRIVATE_IP

if [[ ! -z $PUBLIC_IP ]]; then
        WEBUI_ADDRESS=$PUBLIC_IP
fi

gsed -i "s/%WEBUI_ADDRESS%/${WEBUI_ADDRESS}/" /etc/motd
gsed -i "s/%FUS_PW%/${FUS_PW}/" /etc/motd