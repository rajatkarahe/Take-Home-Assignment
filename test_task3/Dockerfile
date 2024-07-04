FROM ubuntu:latest

# Set environment variables to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Update the package repository and install PostgreSQL
RUN apt-get update && \
    apt-get install -y gnupg2 wget lsb-release && \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list && \
    apt-get update && \
    apt-get install -y postgresql-13

# Create directory for PostgreSQL data
RUN mkdir -p /var/lib/postgresql/data && chown -R postgres:postgres /var/lib/postgresql/data

# Copy entrypoint script and make it executable
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose PostgreSQL port
EXPOSE 5432

# Set the data directory as a volume
VOLUME /var/lib/postgresql/data

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
