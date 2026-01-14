# DevOps Assessment Solution

This repository contains a full-stack DevOps solution for deploying a Python web application on Linux containers using Azure Kubernetes Service (AKS), managed via Terraform and Azure DevOps Pipelines.

---

## Tech Stack
* **Cloud Provider:** Microsoft Azure
* **Infrastructure as Code:** Terraform (AzureRM)
* **CI/CD Orchestration:** Azure Pipelines
* **Containerization:** Docker (Linux Containers)
* **Orchestration:** Azure Kubernetes Service (AKS)
* **Source Control:** GitHub & Azure DevOps
* **Language:** Python

---

## System Architecture
The project follows a modular, scalable architecture designed for high availability and security.

* Automated Flow: Every git push triggers a multi-stage pipeline.
* Security: Uses Azure Service Principals and Managed Identities with RBAC-restricted access.
* Persistence: Terraform state is stored securely in an Azure Storage Account with state locking enabled.


### Folder Structure
```text
├── app/                        # Python Application source code
│   ├── main.py                 # Application logic
│   └── Dockerfile              # Linux container definition
├── terraform/
│   ├── modules/                # Reusable Infrastructure modules
│   │   ├── networking/               # Virtual Network, Subnets, & NSGs
│   │   ├── aks/                # AKS Cluster & RBAC settings
│   │   └── monitoring/         # Azure Monitor & Log Analytics
│   └── environments/           # Environment-specific configurations
│       ├── dev/                # Development variables & backend config
│       ├── test/               # Test environment configurations
│       └── prod/               # Production configuration (Future scaling)
├── kubernetes/                 # K8s Manifests (Deployments, Services)
└── azure-pipelines.yml         # CI/CD Multi-stage pipeline definition
```
---

## CI/CD Pipeline Workflow
The pipeline is a parameter-driven, multi-stage YAML definition designed for both Deployment and Destruction of environments.

* **Stage-by-Stage Breakdown:**
* **Build Stage (Linux Containers):** Builds the Docker image from app/Dockerfile, tags it with the Build ID, and pushes it to Azure Container Registry (ACR).

* **Terraform Validate & Plan:** Initializes the remote backend, validates syntax, and generates a plan output to preview infrastructure changes.

* **Manual Approval Gate:** The pipeline pauses for a human reviewer to inspect the Terraform Plan logs. This ensures no accidental deletions occur.

* **Terraform Execution:** Executes terraform apply (or destroy) using -lock=false for resiliency.

* **Deploy to AKS:** Applies Kubernetes manifests using kubectl. It dynamically updates the image tag to the latest build to ensure a zero-downtime-like deployment.

---

## Deployment Verification & Access
Self-Hosted Agent Pool: A private Ubuntu Linux agent was configured as a Self-Hosted Agent in Azure DevOps. This allows the pipeline to run within a secure network and have direct access to internal CLI tools.

The application has been successfully deployed as a Linux Container within the AKS cluster. It is exposed to the public internet via an Azure Load Balancer.

* **Visit the URL:** Open your web browser and navigate to the EXTERNAL-IP http://48.202.136.241
