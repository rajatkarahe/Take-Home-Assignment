# Dockerfile for PostgreSQL 13 Installation and Configuration

This Dockerfile installs PostgreSQL 13, creates a new user and database, and configures PostgreSQL to allow remote connections.

## Fixes Implemented:
- Corrected PostgreSQL installation to version 13 using PGDG repository.
- Fixed `sed` command to properly update `postgresql.conf`.
- Separated `CMD` instructions to ensure PostgreSQL starts correctly.

## Extra Credit #1: Secret Encryption Solution
To implement secret encryption for PostgreSQL credentials:
- You can export environment variable, and then use it in your dockerfile. Update Dockerfile to Accept the build argument.
Dockerfile:
ARG POSTGRES_PASSWORD

```sh
export POSTGRES_PASSWORD=mypassword
docker build --build-arg POSTGRES_PASSWORD=$POSTGRES_PASSWORD -t postgres-image-secret .
docker run -d -p 5432:5432 --name my-postgres-container postgresql-image
#Verify PostgresSQL Connectivity
psql -h localhost -U myuser -d mydatabase

```
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



## Extra Credit #2: Troubleshooting Steps for Running Container Issues
To troubleshoot issues with a running container:
1. **Check Container Logs**: Use `docker logs <container_id>` to view PostgreSQL and system logs.
2. **Service Status**: Run `docker exec -it <container_id> service postgresql status` to check PostgreSQL service status inside the container.
3. **Network Configuration**: Ensure PostgreSQL is listening on the correct interface and port. Use `docker exec -it <container_id> cat /etc/postgresql/13/main/postgresql.conf` to verify `listen_addresses`.
4. **Firewall Settings**: Confirm that firewall settings (`ufw`, `iptables`) allow incoming connections to port 5432.
5. **Container Health**: Monitor container health with `docker ps` and check for any abnormal exits or restarts.
6. **Service Restart**: If needed, restart PostgreSQL service inside the container with `docker exec -it <container_id> service postgresql restart`.

## Building and Running the Docker Image
1. **Build Docker Image**:
```sh
docker build -t postgresql-image .
#Run Docker Container
docker run -d -p 5432:5432 --name my-postgres-container postgresql-image
#Verify PostgresSQL Connectivity
psql -h localhost -U myuser -d mydatabase

#Output of Working Version
#Upon successful connectivity using psql, you should see:
psql (13.x)
Type "help" for help.

mydatabase=#
```

### Summary:
This README.md provides comprehensive documentation addressing the assignment requirements, including fixing Dockerfile1, implementing optional extra credit solutions, and outlining troubleshooting steps for container issues. Adjustments may be needed based on specific environment configurations or additional requirements.


