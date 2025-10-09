# AWS Web Application Infrastructure with Terraform  

This project demonstrates how to use **Terraform** to provision a highly available web application on AWS. The setup includes a **custom VPC, subnets, Internet Gateway, EC2 instances, Security Groups, S3 bucket, and an Application Load Balancer (ALB)** to host a simple Apache-based web application.  

---

## Project Overview  

The goal of this project is to build a **scalable and fault-tolerant web application infrastructure** on AWS using Terraform as Infrastructure as Code (IaC).  

Key highlights of this project:  
- Two Apache web servers deployed across different Availability Zones.  
- Application Load Balancer (ALB) distributing traffic between servers.  
- Custom VPC with public subnets, routing, and internet connectivity.  
- Security groups to control traffic.  
- An S3 bucket for storage.  
- Fully automated deployment with Terraform.  

---

## Infrastructure Components  

### 1. VPC  
- Custom VPC with CIDR block `10.0.0.0/16`.  
- Provides isolated networking for resources.  

### 2. Subnets  
- **Subnet 1** → `10.0.0.0/24` in `us-east-1a`.  
- **Subnet 2** → `10.0.1.0/24` in `us-east-1b`.  
- Configured as public subnets with automatic public IP assignment.  

### 3. Internet Gateway & Route Tables  
- Internet Gateway for external connectivity.  
- Route table routes `0.0.0.0/0` through IGW.  
- Both subnets associated with this route table.  

### 4. Security Group  
- Allows inbound traffic on:  
  - **HTTP (80)** → web traffic.  
  - **SSH (22)** → remote access.  
- Allows all outbound traffic.  

### 5. EC2 Instances  
- Two **t3.micro** EC2 instances.  
- Each in a separate subnet for high availability.  
- Configured with **user data scripts**:  
  - Install Apache web server.  
  - Deploy custom HTML pages (`Welcome to Webserver 1` and `Welcome to Webserver 2`).  
  - Start Apache service.  

### 6. Application Load Balancer (ALB)  
- Public ALB spanning across both subnets.  
- Target group on port 80 with health checks on `/`.  
- Listener forwards requests to the target group.  
- Distributes traffic between EC2 instances.  

### 7. S3 Bucket  
- An AWS S3 bucket created for object storage.  
- Can be used for logs, backups, or static content.  

### 8. Outputs  
- Terraform outputs the ALB DNS name after deployment.  
- Use this DNS to access the load-balanced web application.  

---

## How It Works  

1. User accesses the **ALB DNS name** in a browser.  
2. ALB forwards request to one of the EC2 instances.  
3. The selected EC2 instance serves its HTML page.  
   - Sometimes: `Welcome to Webserver 1`.  
   - Sometimes: `Welcome to Webserver 2`.  
4. Load balancing ensures **high availability and fault tolerance**.  

---

## Tools & Technologies  

- **Terraform** → Infrastructure as Code.  
- **AWS VPC** → Networking.  
- **AWS EC2** → Web servers.  
- **AWS ALB** → Load balancing.  
- **AWS S3** → Storage.  
- **Apache Web Server** → Web hosting.  
- **User Data Scripts** → Server automation.  

---

## Architecture Diagram

                    +-------------------------+
                    |   Application Load      |
                    |     Balancer (ALB)      |
                    +-----------+-------------+
                                |
                ----------------+----------------
                |                               |
        +-------v-------+               +-------v-------+
        |   EC2 in AZ1  |               |   EC2 in AZ2  |
        | Apache Server |               | Apache Server |
        +---------------+               +---------------+

  

