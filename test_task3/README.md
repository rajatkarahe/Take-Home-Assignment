# Dockerfile for PostgreSQL 13 Installation and Configuration

This Dockerfile installs PostgreSQL 13, creates a new user and database, and configures PostgreSQL to allow remote connections.

## Fixes Implemented:
- Corrected PostgreSQL installation to version 13 using PGDG repository.
- Fixed `sed` command to properly update `postgresql.conf`.
- Separated `CMD` instructions to ensure PostgreSQL starts correctly.

### Dockerfile Configuration for PostgreSQL Data Persistence
The provided Dockerfile ensures PostgreSQL data persistence by:

**Create directory for PostgreSQL data**
```sh
RUN mkdir -p /var/lib/postgresql/data && chown -R postgres:postgres /var/lib/postgresql/data
```
Creates a directory /var/lib/postgresql/data inside the container for storing PostgreSQL data and sets ownership to the postgres user.

**Setting Data Directory as a Volume:**
```sh
VOLUME /var/lib/postgresql/data
```
Configures /var/lib/postgresql/data as a Docker volume, ensuring data persists on the host machine even if the container stops or is removed.

**Usage**
When running the Docker container, use the -v or --volume flag to specify a path on the host machine where PostgreSQL data should be stored:
```sh
docker run -d -p 5432:5432 -v /path/on/host:/var/lib/postgresql/data postgres-image
```

Replace /path/on/host with your preferred directory path on the host machine.

## Extra Credit #1: Secret Encryption Solution
To implement secret encryption for PostgreSQL credentials:
- Use Docker secrets or environment variables to securely pass credentials to the containerized application.
For that follow the below:
Update the Dockerfile to use docker secrets:
Dockerfile:
RUN service postgresql start && \
    su - postgres -c "psql -c \"CREATE USER myuser WITH PASSWORD '$(cat /run/secrets/postgres_password)';\"" && \
    su - postgres -c "createdb -O myuser mydatabase"
    
```sh
#Get the ip addr from 
ip addr show

docker swarm init --advertise-addr 192.168.29.22
echo "mypassword" | docker secret create postgres_password -
```

- **Usage of Vault for PostgreSQL Secret Encryption**
    Setup Vault: Ensure Vault is initialized and unsealed with appropriate access policies for PostgreSQL secrets.

    **Store PostgreSQL Credentials: Use Vault to securely store PostgreSQL credentials as a key-value pair:**

    vault kv put secret/postgres-creds username=myuser password=mypassword

    **Access PostgreSQL Secrets: Configure your application or service to retrieve PostgreSQL credentials from Vault:**

    vault kv get -field=username secret/postgres-creds

    **Dockerfile Integration: Add Vault CLI installation and configuration steps to your Dockerfile for secrets retrieval:**

```sh
RUN apk add --no-cache curl
RUN curl -fsSL -o /tmp/vault.zip https://releases.hashicorp.com/vault/X.X.X/vault_X.X.X_linux_amd64.zip \
    && unzip /tmp/vault.zip -d /usr/local/bin/ \
    && rm /tmp/vault.zip
ENV VAULT_ADDR=http://vault:8200
#Replace X.X.X with the latest version of Vault. Ensure Vault is accessible via VAULT_ADDR environment variable.
```

## Extra Credit #2: Troubleshooting Steps for Running Container Issues
To troubleshoot issues with a running container:
1. **Check Container Logs**: Use `docker logs <container_id>` to view PostgreSQL and system logs.
2. **Service Status**: Run `docker exec -it <container_id> service postgresql status` to check PostgreSQL service status inside the container.
3. **Network Configuration**: Ensure PostgreSQL is listening on the correct interface and port. Use `docker exec -it <container_id> cat /etc/postgresql/13/main/postgresql.conf` to verify `listen_addresses`.
4. **Firewall Settings**: Confirm that firewall settings (`ufw`, `iptables`) allow incoming connections to port 5432.
5. **Container Health**: Monitor container health with `docker ps` and check for any abnormal exits or restarts.
6. **Service Restart**: If needed, restart PostgreSQL service inside the container with `docker exec -it <container_id> service postgresql restart`.
7. **Check port usage with netstat:** Ensure port 5432 (default PostgreSQL port) isn't in use or blocked by another process. Adjust the port number as per your PostgreSQL configuration.
```sh
netstat -tuln | grep :5432
```


## Building and Running the Docker Image
1. **Build Docker Image**:
```sh
docker build -t postgresql-image .
#Run Docker Container
docker run -d -p 5432:5432 --name postgres-container postgresql-image
#Verify PostgresSQL Connectivity
psql -h localhost -U myuser -d mydatabase

#Output of Working Version
#Upon successful connectivity using psql, you should see:
psql (13.x)
Type "help" for help.

mydatabase=#
```
![alt text](<Screenshot from 2024-06-21 15-44-28.png>)

### Summary:
This README.md provides comprehensive documentation addressing the assignment requirements, including fixing Dockerfile1, implementing optional extra credit solutions, and outlining troubleshooting steps for container issues. Adjustments may be needed based on specific environment configurations or additional requirements.


