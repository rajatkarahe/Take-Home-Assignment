# Ansible Nginx Setup

This repository contains Ansible playbooks and configurations to set up a Nginx web server on multiple EC2 instances and display a custom "Hello World" page.

## Prerequisites

1. **EC2 Instances**
   - Create two EC2 instances with Ubuntu and ensure they are running. [allow inbound traffic on port 80]
   - Attach a security group that allows inbound traffic on port 80 (HTTP).

2. **SSH Key**
   - Create a PEM file (`ansible.pem`) to access the EC2 instances.
   - Transfer the PEM file to your local machine and ensure it has the correct permissions:
     ```sh
     chmod 400 ansible.pem
     ```

3. **Ansible Installed on Local Machine**
   - Install Ansible and Python on your local machine:
```sh
    #create a python virtual environment
     python3 -m venv ./venev && source ./venv/bin/activate
     (venv) user@user:~/home/ pip3 install ansible=8.x.x
     ansible --version
     python3 --version
```

## Setup Steps

1. **Update Inventory File**
   - Modify the inventory file (`inventory`) to include the public IP addresses of your EC2 instances:
     ```ini
     [all]
     3.95.57.6 ansible_ssh_user=ubuntu ansible_ssh_private_key_file=ansible.pem
     44.223.32.191 ansible_ssh_user=ubuntu ansible_ssh_private_key_file=ansible.pem
     localhost ansible_connection=local
     ```

2. **Run Ansible Ping to Test Connectivity of EC2 instances**
   - Verify Ansible can communicate with the EC2 instances: 
     ```sh
     ansible -i inventory -m ping all
     ```

3. **Run the Ansible Playbook**
   - Execute the playbook to set up Nginx and deploy the webpage:
     ```sh
     ansible-playbook -i inventory --ask-become-pass playbook.yml
     ```

## Verify the Setup

1. **Check Nginx Status on EC2 Instances**
   - SSH into each EC2 instance to verify Nginx status:
     ```sh
     ssh -i ansible.pem ubuntu@3.95.57.6
     sudo systemctl status nginx
     ```

2. **Verify the Webpage in Browser**
   - Open a browser and go to `http://3.95.57.6/hello-world/` to see the custom "Hello World" page.

3. **Check HTML Content on EC2 Instances**
   - SSH into each EC2 instance to check the deployed HTML content:
     ```sh
     ssh -i ansible.pem ubuntu@3.95.57.6
     cat /var/www/html/index.html
     ```

4. **Test Connectivity with `curl`**
- Test access to the webpage using `curl`:
```sh
     curl http://3.95.57.6/hello-world/
```

## Troubleshooting

1. **Ensure Nginx is Running**
```sh
   sudo systemctl status nginx
   #check port listening
   sudo netstat -tuln | grep :80
   #check firewall rules
   sudo ufw status
   #check nginx logs
   sudo tail -f /var/log/nginx/error.log
   sudo tail -f /var/log/nginx/access.log
```

# Server Configuration and Logging with Ansible

This Ansible project automates server configuration tasks and implements logging using Fluentd for Nginx access logs. It also includes configuring log rotation and setting up firewall rules using UFW.

## Tasks Overview

### 1. Install OS Packages

- **Purpose:** Installs essential OS packages required for server operations.
- **Packages Installed:**
  - `libcurl4-gnutls-dev`: Development files for libcurl (CURL library).
  - `build-essential`: Essential build tools needed for compiling software.

### 2. Install Fluentd on Debian/Ubuntu

- **Purpose:** Installs Fluentd (td-agent) for log aggregation and processing.
- **Method:** Uses a shell script to download and install Fluentd from Treasure Data's repository.

### 3. Install Fluentd Plugins

- **Purpose:** Installs necessary Fluentd plugins to enhance log processing capabilities.
- **Plugins Installed:**
  - `fluent-plugin-parser`: Parses log entries.
  - `fluent-plugin-grep`: Filters log entries based on patterns.
  - `fluent-plugin-rewrite-tag-filter`: Rewrites or modifies log entry tags.

### 4. Copy Fluentd Configuration

- **Purpose:** Deploys a pre-configured Fluentd configuration file to define log sources, filters, and destinations.
- **Location:** `/etc/td-agent/td-agent.conf`
- **Ownership:** The configuration file is owned by `td-agent` user and group (`td-agent:td-agent`).

### 5. Validate Fluentd Configuration

- **Purpose:** Checks the syntax and validity of the Fluentd configuration file.
- **Validation Command:** `td-agent --dry-run -c /etc/td-agent/td-agent.conf`
- **Success Criteria:** The command should exit with a status code of `0` indicating no syntax errors.

### 6. Restart Fluentd Service

- **Purpose:** Ensures that the Fluentd service is restarted after configuration changes.
- **Restart Command:** `service td-agent restart`
- **Condition:** Only restarts if the configuration validation (step 5) is successful.

### 7. Deploy Logrotate Configuration for Nginx Access Log

- **Purpose:** Configures log rotation for Nginx access logs to manage log size and retention.
- **Location:** `/etc/logrotate.d/nginx-access`
- **Features:** Rotates logs daily, keeps logs for up to 5 days, compresses old logs, and triggers Nginx log rotation.

### 8. Configure UFW

- **Purpose:** Sets up basic firewall rules using UFW to restrict access to the server.
- **Rule:** Allows incoming TCP traffic on port `80` (HTTP).

## Testing and Verification

To ensure proper setup and functionality of the configurations:

1. **Check Fluentd Service Status:**
   - Verify that the Fluentd service (`td-agent`) is running:
     ```bash
     sudo service td-agent status
     ```

2. **Verify Nginx Service Restart:**
   - Confirm that Nginx has restarted after logrotate configuration deployment:
     ```bash
     sudo service nginx status
     ```

3. **Validate Fluentd Configuration:**
   - Run the validation command to check the Fluentd configuration:
     ```bash
     sudo td-agent --dry-run -c /etc/td-agent/td-agent.conf
     ```

4. **Check Log Rotation:**
   - Monitor the log rotation process for Nginx access logs and verify rotation:
     ```bash
     sudo logrotate -d /etc/logrotate.d/nginx-access
     ```

5. **Firewall Rules Verification:**
   - Ensure that UFW is active and allowing traffic on port `80`:
     ```bash
     sudo ufw status
     ```

## Additional Information

- **Ansible Playbook:** This project is managed through an Ansible playbook (`playbook.yml`) which orchestrates the tasks described above.
- **Fluentd Configuration:** The `fluentd.conf.j2` template file contains the configuration used for Fluentd, located in `templates/fluentd.conf.j2`.
- **Server Requirements:** Ensure the target server is a Debian/Ubuntu system with internet access for package installation and Fluentd setup.


