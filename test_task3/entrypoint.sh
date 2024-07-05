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


# Check if user exists
USER_EXISTS=$(su - postgres -c "psql -tAc \"SELECT 1 FROM pg_roles WHERE rolname='$POSTGRES_USER'\"")

if [ -z "$USER_EXISTS" ]; then
  su - postgres -c "psql -c \"CREATE USER ${POSTGRES_USER} WITH PASSWORD '${POSTGRES_PASSWORD}';\""
else
  echo "User $POSTGRES_USER already exists"
fi

# Check if database exists
DB_EXISTS=$(su - postgres -c "psql -tAc \"SELECT 1 FROM pg_database WHERE datname='$POSTGRES_DB'\"")

if [ -z "$DB_EXISTS" ]; then
  su - postgres -c "createdb -O ${POSTGRES_USER} ${POSTGRES_DB}"
else
  echo "Database $POSTGRES_DB already exists"
fi

# Execute any additional commands
exec "$@"
