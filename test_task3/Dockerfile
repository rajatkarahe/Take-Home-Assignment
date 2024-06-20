FROM ubuntu:latest

# ARG POSTGRES_PASSWORD

# Update the package repository and install PostgreSQL
RUN apt-get update && \
    apt-get install -y gnupg2 wget lsb-release && \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list && \
    apt-get update && \
    apt-get install -y postgresql-13

# Create directory for PostgreSQL data
# RUN mkdir -p /var/lib/postgresql/data && chown -R postgres:postgres /var/lib/postgresql/data

# RUN service postgresql start && \
#     su - postgres -c "psql -c \"CREATE USER myuser WITH PASSWORD '$(cat /run/secrets/postgres_password)';\"" && \
#     su - postgres -c "createdb -O myuser mydatabase"

#Implement a secret access solution n in order to prevent exposure of the postgres db credentials.
# RUN service postgresql start && \
#     su - postgres -c "psql -c \"CREATE USER myuser WITH PASSWORD '${POSTGRES_PASSWORD}';\"" && \
#     su - postgres -c "createdb -O myuser mydatabase"

RUN service postgresql start && \
    su - postgres -c "psql -c \"CREATE USER myuser WITH PASSWORD 'mypassword';\"" && \
    su - postgres -c "createdb -O myuser mydatabase"

# Update postgresql.conf and pg_hba.conf to allow remote connections
RUN sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/13/main/postgresql.conf && \
    echo "host all all 0.0.0.0/0 trust" >> /etc/postgresql/13/main/pg_hba.conf

# Expose PostgreSQL port
EXPOSE 5432

# Set the data directory as a volume
# VOLUME /var/lib/postgresql/data

CMD service postgresql start && tail -f /dev/null
