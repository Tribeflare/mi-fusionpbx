# Get password from metadata, unless passed as PGSQL_PW, or set one.
log "getting pgsql_pw"
PGSQLPASS=${PGSQLPASS:-$(mdata-get pgsqlpass 2>/dev/null)} || \
PGSQLPASS="postgres";

echo "${PGSQLPASS}" > /tmp/pgpasswd

[[ -d "/var/pgsql/data" ]] && rm -rf /var/pgsql/data

log "initializing PostgreSQL"
su - postgres -c "/opt/local/bin/initdb \
                  --pgdata=/var/pgsql/data \
                  --encoding=UTF8 \
                  --locale=en_US.UTF-8 \
                  --auth=password \
                  --pwfile=/tmp/pgpasswd" >/dev/null || \
  (log "PostgreSQL init command failed" && exit 31);

rm /tmp/pgpasswd

log "starting PostgreSQL"
svcadm enable -s postgresql

