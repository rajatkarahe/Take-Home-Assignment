#!/bin/bash
# entrypoint.sh

# Load environment variables from .env file if present
if [ -f /app/.env ]; then
  export $(cat /app/.env | grep -v '#' | awk '/=/ {print $1}')
fi

# Start PostgreSQL service
service postgresql start

sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/13/main/postgresql.conf 


# Modify pg_hba.conf to use md5 for all connections
echo "host all all 127.0.0.1/32 md5" >> /etc/postgresql/13/main/pg_hba.conf
echo "host all all ::1/128 md5" >> /etc/postgresql/13/main/pg_hba.conf
echo "host all all 0.0.0.0/0 md5" >> /etc/postgresql/13/main/pg_hba.conf
echo "host all all 0.0.0.0/0 trust" >> /etc/postgresql/13/main/pg_hba.conf

# Restart PostgreSQL service to apply changes
service postgresql restart

# Create user and database using environment variables
su - postgres -c "psql -c \"CREATE USER ${POSTGRES_USER} WITH PASSWORD '${POSTGRES_PASSWORD}';\""
su - postgres -c "createdb -O ${POSTGRES_USER} ${POSTGRES_DB}"

# Keep the container running
tail -f /dev/null

# Execute any additional commands
exec "$@"
