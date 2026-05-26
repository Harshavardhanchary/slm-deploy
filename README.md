# AI SLM Deployment

## Overview

This repository provisions and deploys a distributed AI inference system on AWS.

The solution uses a three-node architecture:

- **API VM** – exposes the public JSON API and runs the III engine.
- **Caller Worker VM** – coordinates requests through RPC.
- **Inference Worker VM** – executes model inference.

Infrastructure is provisioned with Terraform, services are managed with systemd, and all worker-to-worker communication occurs exclusively over private VPC networking.

---
## Pre-Deployment Configuration

Before deploying the infrastructure, update the following values.

### 1. Update `terraform.tfvars`

Set `my_ip` to the public IP address of the machine from which you will access the environment.

Find your public IP:

```bash
curl ifconfig.me
```
---

### 2. Update Systemd Service Files

The worker services must be configured with the private IP address of the API VM running the III engine.

After the API VM is created, obtain its private IP:

```
hostname -I
```

or

```
ip addr show
```
or 

In terraform outputs 

Example:

```
Environment=III_URL=ws://10.0.0.48:49134  in systemd service files
```
## Deployment Approach  
  
Terraform provisions all networking and compute resources.  
  
Software installation and worker configuration are performed using the scripts located under:  
  
```text  
scripts/  
```  
  
Systemd unit files are provided under:  
  
```text  
systemd/  
```
---
# Architecture

```text

                           ┌──────────────────┐
                           │     Internet     │
                           └────────┬─────────┘
                                    │
                                    │
                          Public Endpoint :3111
                                    │
                                    ▼

                    ┌──────────────────────────────┐
                    │         API VM               │
                    │------------------------------│
                    │ III Engine                   │
                    │ REST API                     │
                    │ Public Subnet                │
                    └──────────────┬───────────────┘
                                   │
                                   │ RPC
                                   │
          ┌────────────────────────┴────────────────────────┐
          │                                                 │
          ▼                                                 ▼

┌───────────────────────┐                  ┌───────────────────────┐
│   Caller Worker VM    │                  │ Inference Worker VM   │
│-----------------------│                  │-----------------------│
│ caller-worker         │ ───────────────► │ inference-worker      │
│ Private Subnet        │      RPC         │ SLM Model             │
└───────────────────────┘                  └───────────────────────┘

          Private VPC Network (No Public Access)

                                   │
                                   ▼

                           ┌──────────────┐
                           │ NAT Gateway  │
                           └──────┬───────┘
                                  │
                                  ▼
                              Internet

```
---

# Network Design

## Public Resources

### API VM

- Public subnet
- Public IP attached
- Exposes:
  - TCP 22 (SSH)
  - TCP 3111 (Inference API)

### NAT Gateway

- Public subnet
- Provides outbound internet access for private workers

---

## Private Resources

### Caller Worker VM

- Private subnet
- No public IP
- Accessible only through private VPC network

### Inference Worker VM

- Private subnet
- No public IP
- Accessible only through private VPC network

---

# RPC Flow

```text
Client
  |
  v
API VM (REST API)
  |
  v
Caller Worker
  |
  v
Inference Worker
  |
  v
Model Response
  |
  v
Caller Worker
  |
  v
API VM
  |
  v
Client
```

---

# Repository Structure

```text
.
├── README.md
├── quickstart
│   ├── config.yaml
│   ├── iii.lock
│   ├── iii.worker.yaml
│   └── workers
│       ├── caller-worker
│       └── inference-worker
│
├── terraform
│   ├── provider.tf
│   ├── variables.tf
│   ├── vpc.tf
│   ├── SecurityGroup.tf
│   ├── EC2.tf
│   ├── outputs.tf
│   └── terraform.tfvars
│
├── systemd
│   ├── iii.service
│   ├── caller-worker.service
│   └── inference-worker.service
│
└── scripts
    ├── api-vm.sh
    ├── caller-worker.sh
    └── inference-worker.sh
```

---

# API Usage

## Endpoint

```http
POST http://<PUBLIC_IP>:3111/v1/chat/completions
```

---

## Example Request

```bash
curl -X POST http://<PUBLIC_IP>:3111/v1/chat/completions \
-H "Content-Type: application/json" \
-d '{
  "messages": [
    {
      "role": "user",
      "content": "What is Docker?"
    }
  ]
}'
```

---

## Example Response

```json
{
  "result": "Docker is a family name that is associated with the Docker family."
}
```

> Note: The supplied model in the quickstart project is intentionally small and primarily used to validate end-to-end RPC communication.

---

# Infrastructure Provisioning

## Prerequisites

Install:

- Terraform >= 1.5
- AWS CLI
- Git

Configure AWS credentials:

```bash
aws configure
```

---

# Deployment Steps

## 1. Provision Infrastructure  
  
Navigate to the Terraform directory:  
  
```bash  
cd terraform  
```  
  
Initialize Terraform:  
  
```bash  
terraform init  
```  
  
Review the plan:  
  
```bash  
terraform plan  
```  
  
Deploy infrastructure:  
  
```bash  
terraform apply  
```  
  
Terraform creates:  
  
- VPC  
- Public Subnet  
- Private Subnet  
- Internet Gateway  
- NAT Gateway  
- Route Tables  
- Security Groups  
- API VM(Main-EC2)
- Caller Worker VM  
- Inference Worker VM  
- SSH Key Pair
---
# Worker Deployment

## 2. Configure API VM

SSH into the API VM:

```bash
ssh -i slm-key.pem ubuntu@<API_PUBLIC_IP>
```

Clone repository:

```bash
git clone https://github.com/Harshavardhanchary/slm-deploy.git
cd <repo-name>
```

Run installation script:

```bash
chmod +x scripts/api-vm.sh
./scripts/api-vm.sh
```

Install systemd service:

```bash
sudo cp systemd/iii.service /etc/systemd/system/

sudo systemctl daemon-reload
sudo systemctl enable iii
sudo systemctl start iii
```

Verify:

```bash
sudo systemctl status iii
```
---

## 3. Configure Caller Worker VM

From API VM connect to Caller Worker VM:

```bash
ssh -i slm-key.pem ubuntu@<CALLER_PRIVATE_IP>
```

Clone repository:

```bash
git clone https://github.com/Harshavardhanchary/slm-deploy.git
cd slm-deploy
```

Run installation script:

```bash
chmod +x scripts/caller-worker.sh
./scripts/caller-worker.sh
```

Install Node dependencies (IMPORTANT):

```
cd quickstart/workers/caller-worker
npm install
cd ../../../
```
### Configure III Engine URL

Obtain the API VM private IP:

```
hostname -I
```

Example output:

```
10.0.0.174
```

Update the following line in service file:

```
Environment=III_URL=ws://10.0.0.174:49134
```
Install systemd service:

```bash
sudo cp systemd/caller-worker.service /etc/systemd/system/

sudo systemctl daemon-reload
sudo systemctl enable caller-worker
sudo systemctl start caller-worker
```

Verify:

```bash
sudo systemctl status caller-worker
```
---


## 4. Configure Inference Worker VM

From API VM connect to Inference Worker VM:

```bash
ssh -i slm-key.pem ubuntu@<INFERENCE_PRIVATE_IP>
```

Clone repository:

```bash
git clone https://github.com/Harshavardhanchary/slm-deploy.git
cd slm-deploy
```

Run installation script:

```bash
chmod +x scripts/inference-worker.sh
./scripts/inference-worker.sh
```
Set up Python environment and dependencies:

```
cd quickstart/workers/inference-worker
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
deactivate
cd ../../../
```

Install systemd service:

```bash
sudo cp systemd/inference-worker.service /etc/systemd/system/

sudo systemctl daemon-reload
sudo systemctl enable inference-worker
sudo systemctl start inference-worker
```

Verify:

```bash
sudo systemctl status inference-worker
```
# Configure III Engine URL

Both worker services must point to the III engine running on the API VM.

Obtain the API VM (Main VM in which iii service runs )private IP:

```
hostname -I
```

Example output:

```
10.0.0.174
```

Update the following line in both service files:

```
Environment=III_URL=ws://10.0.0.174:49134
```

---
# Production Hardening

Before deploying this architecture to production, the following improvements would be implemented:

### Network Security

- Restrict SSH access to trusted IP ranges.
- Remove SSH exposure entirely and use AWS Systems Manager Session Manager.
- Use dedicated security groups per service.
- Enable VPC Flow Logs.

### Secrets Management

- Store secrets in AWS Secrets Manager.
- Remove credentials from configuration files.
- Use IAM roles instead of long-lived credentials.

### Monitoring & Observability

- CloudWatch metrics and alarms.
- Centralized log aggregation.
- Distributed tracing across workers.

### Availability

- Multi-AZ deployment.
- Auto Scaling Groups.
- Load balancer in front of API nodes.
- Automated backups and disaster recovery procedures.

---

# Scaling for a Model 100x Larger

The current architecture uses a small CPU-based model suitable for demonstration purposes.

If the model size increased by 100x:

### Inference Infrastructure

- Move inference workloads to GPU instances.
- Use dedicated inference clusters.
- Deploy models using vLLM or TensorRT-LLM.
- Use model sharding and tensor parallelism.

### Storage

- Store model artifacts in S3.
- Cache models locally on inference nodes.
- Use EFS/FSx for shared model storage.

### Scalability

- Horizontal scaling of inference workers.
- Queue-based request processing.
- Load balancing across inference nodes.
- Use container orchestration (e.g., Kubernetes) for improved scalability and service management.

### Reliability

- Dedicated model serving platform.
- Health checks and automated failover.
- Separate orchestration and inference tiers.

---

# Result

The deployment successfully demonstrates:

- Infrastructure provisioned using Terraform.
- Workers isolated in private subnets.
- RPC communication over private VPC networking.
- Public JSON API endpoint.
- End-to-end inference flow from API → Caller Worker → Inference Worker → API response.
- Reproducible deployment in a clean AWS account.
