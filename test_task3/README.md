# Dockerfile for PostgreSQL 13 Installation and Configuration

This Dockerfile installs PostgreSQL 13, creates a new user and database, and configures PostgreSQL to allow remote connections.

## Fixes Implemented:
- Corrected PostgreSQL installation to version 13 using PGDG repository. As not specifying the version may lead to the latest version installation which is version 13.
- Double quotes (`"`) were used around the sed command. This allows for variable expansion (`* and /`) within the sed command itself.
- `ENTRYPOINT` combined with `exec "$@"` allows for flexibility in running additional commands or overriding the default behavior of the container at runtime. Users can specify commands or arguments when starting the container, which will be executed in place of `tail -f /dev/null`.
- Added a check to the create user and database command to handle the case of container restart

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
- **Secret Implementation:**

Sensitive database credentials (`POSTGRES_USER and POSTGRES_PASSWORD`) are sourced from an `.env` file within the container's environment. To enhance security.

You consider using a secret management solution like Docker secrets, Kubernetes secrets, or environment encryption tools to further protect these credentials from exposure in plain text.

- **Use Docker secrets or environment variables to securely pass credentials to the containerized application.**
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
7. **Check port usage with netstat:** Ensure port 5432 (default PostgreSQL port) isn't in use or blocked by another process. Adjust the port number as per your PostgreSQL configuration.
```sh
netstat -tuln | grep :5432
```


## Building and Running the Docker Image
1. **Build Docker Image**:
```sh
docker build -t my_postgres_image .
#Run Docker Container
docker run -p 5432:5432 --env-file .env -d --name my_postgres_container my_postgres_image
```
Also you can test the database like this:
```sh
#get inside the postgres container
docker exec -it my_postgres_container bash
```
![alt text](<Screenshot from 2024-07-04 10-31-54.png>)

```sh
#Or you can access the database from localhost
psql -h localhost -U myuser mydatabase

```
![alt text](<Screenshot from 2024-07-04 10-36-38.png>)

### Summary:
This README.md provides comprehensive documentation addressing the assignment requirements, including fixing Dockerfile1, implementing optional extra credit solutions, and outlining troubleshooting steps for container issues. Adjustments may be needed based on specific environment configurations or additional requirements.


