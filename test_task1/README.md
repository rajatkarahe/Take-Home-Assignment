### Configuring the EC2 instance to install Nginx: 
It is done using the `user_data` script in the `aws_instance` resource above. The script is responsible to updates the package lists, install Nginx, starts the Nginx service, and ensures it starts on boot.

Security for the server is managed by the security group `nginx_sg` defined above, which allows incoming HTTP traffic on port 80.

# Terraform Nginx Server on AWS

This repository contains Terraform configuration files to provision an EC2 instance running Ubuntu 20.04 with Nginx installed.

## Prerequisites

- Terraform installed (>= 0.12)
- AWS account with access keys configured
- AWS CLI installed and configured (optional)

## Usage

1. Clone the repository:

```sh
git clone https://github.com/your-repo/terraform-nginx-server.git
cd terraform-nginx-server
```

2. Initialize Terraform:

```sh
terraform init
```

3. Review the plan:
```sh
terraform plan
```

4. Apply the configuration:
```sh
terraform apply
```

5. Confirm the apply setup with yes.

### Accessing the Nginx Server
Once the apply step completes, the public IP address of the EC2 instance will be displayed.
You  can access the Nginx server by entering this IP Address in your web browser.

```sh
Outputs:

public_ip = "x.x.x.x"
```
Open your web browser and navigate to `http://x.x.x.x.`


### Extra Credit: Terraform State Management.

#### Why terraform state management is needed?
Terraform state management is crucial for tracking the current state of the infrastructure. 

It helps in:

1. Tracking Resource Changes: Keeps track of the real-time state of infrastructure, allowing Terraform to make updates and deletions accurately.

2. Collaboration: Allows multiple team members to work on the same infrastructure without conflicts.

3. Drift Detection: Detects changes made outside Terraform, ensuring the configuration remains as intended.
Proposed

##### Proposed Solution
**Method:** Remote backend(using AWS S3).

**Configuration:**
```sh
terraform {
  backend "s3" {
    bucket = "your-terraform-state-bucket"
    key    = "terraform/state"
    region = "us-west-2"
  }
}
```

**Pros:**
- Centralized state management
- Easy collaboration
- High durability and availability

**Cons:**
- Potential additional costs for S3 storage
- Requires managing AWS credentials and permissions

**Tradeoffs:**
Using an S3 backend adds a slight complexity in setup but provides significant benefits in terms of durability, availability, and collaboration capabilities. For small teams or individual projects, local state management might suffice, but as the infrastructure grows or team size increases, a remote backend like S3 becomes essential.