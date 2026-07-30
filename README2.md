# LearningSteps Deployment and Architecture Guide

This repository contains the LearningSteps API, a FastAPI application backed by PostgreSQL and deployed to Azure Kubernetes Service (AKS). It also includes Terraform-based infrastructure automation, GitHub Actions CI/CD workflows, and Kubernetes manifests for app deployment.

## Table of Contents

- [Getting Started](#🚀-getting-started)
- [🎯 Development Tasks](#🎯-development-tasks)
  - [1. API Implementation (Required)](#1-api-implementation-required)
  - [2. Logging Setup (Required)](#2-logging-setup-required)
  - [3. Data Model Improvements (Optional)](#3-data-model-improvements-optional)
  - [4. Cloud CLI Setup (Required for Deployment)](#4-cloud-cli-setup-required-for-deployment)
- [Data Schema](#📊-data-schema)
- [Explore Your Database (Optional)](#🔎-explore-your-database-optional)
- [Troubleshooting](#🔧-troubleshooting)
- [What this project does](#what-this-project-does)
- [Features included](#features-included)
- [Project structure](#project-structure)
- [Manual Azure prerequisites](#manual-azure-prerequisites)
- [What files must be updated](#what-files-must-be-updated)
- [Variables to update from manually created Azure resources](#variables-to-update-from-manually-created-azure-resources)
- [GitHub secrets and environment variables needed](#github-secrets-and-environment-variables-needed)
- [Azure permissions required](#azure-permissions-required)
- [Key Vault secrets and keys in scope](#key-vault-secrets-and-keys-in-scope)
- [What the pipelines do](#what-the-pipelines-do)
- [What is in scope for each pipeline](#what-is-in-scope-for-each-pipeline)
- [What is out of scope](#what-is-out-of-scope)
- [How to set this project up and deploy to Azure](#how-to-set-this-project-up-and-deploy-to-azure)
- [Monitoring and observability](#monitoring-and-observability)
- [Important security notes](#important-security-notes)
- [Final summary](#final-summary)

## What this project does

- Runs a Python FastAPI API for a learning journal.
- Stores application data in a PostgreSQL Flexible Server.
- Deploys the app into AKS.
- Uses Azure Container Registry (ACR) for Docker image storage.
- Uses Azure Key Vault for secrets management.
- Automates CI, CD, and infrastructure provisioning via GitHub Actions.

## Features included

- FastAPI REST API for learning journal entries.
- PostgreSQL database schema creation using Kubernetes init Containers.
- ACR image build, scan, and push pipeline.
- AKS deployment with Kubernetes manifests.
- Key Vault secret support and AKS-managed identity access.
- Terraform infrastructure provisioning for Resource Group, VNet, AKS, ACR, Key Vault, and PostgreSQL.
- GitHub Actions CI pipeline for linting, testing, container build, image scanning, and ACR push.
- GitHub Actions CD pipeline for deploying app manifests to AKS.

## Project structure

- `api/` - FastAPI application and business logic.
- `infra-terraform/` - Terraform definitions for Azure resources.
- `k8s-manifests/` - Kubernetes YAMLs for deployment, service, HPA, config, and secrets.
- `.github/workflows/` - GitHub Actions pipelines for CI, CD, and infrastructure.
- `README2.md` - this guide.

## 🚀 Getting Started

Follow these steps to prepare LearningSteps for Azure deployment:

1. Clone the repository and inspect the project structure.
2. Prepare Azure resources manually or using `infra-terraform/`.
3. Configure GitHub Secrets for Azure, ACR, AKS, and PostgreSQL.
4. Run the CI pipeline to validate the application and build the container image.
5. Run the CD pipeline to deploy the app to AKS.

## 🎯 Development Tasks

This section describes the main development tasks for the project.

### 1. API Implementation (Required)

- Implement and validate FastAPI endpoints in `api/`.
- Ensure journal entry CRUD operations are complete.
- Add tests for the API routes and response behavior.

### 2. Logging Setup (Required)

- Configure structured application logging.
- Log startup, request handling, and error events.
- Ensure logs are visible locally and after deployment to AKS.

### 3. Data Model Improvements (Optional)

- Review the current data model and improve table structure.
- Add indexes, constraints, or normalized fields if needed.
- Keep schema changes optional unless required for functionality.

### 4. Cloud CLI Setup (Required for Deployment)

- Install Azure CLI, `kubectl`, and `helm`.
- Authenticate with Azure and select the correct subscription.
- Verify access to AKS and ACR.
- Use CLI tools to run Terraform, deploy Kubernetes manifests, and manage monitoring.

## 📊 Data Schema

The LearningSteps data schema focuses on journal entries and related metadata. PostgreSQL is used as the backing store, and database initialization SQL is defined in `k8s-manifests/configmap.yaml`.

Each journal entry follows this structure:

| Field       | Type      | Description                                | Validation                   |
|-------------|-----------|--------------------------------------------|------------------------------|
| id          | string    | Unique identifier (UUID)                   | Auto-generated               |
| work        | string    | What did you work on today?                | Required, max 256 characters |
| struggle    | string    | What's one thing you struggled with today? | Required, max 256 characters |
| intention   | string    | What will you study/work on tomorrow?      | Required, max 256 characters |
| created_at  | datetime  | When entry was created                     | Auto-generated UTC           |
| updated_at  | datetime  | When entry was last updated                | Auto-updated UTC             |

### Typical schema elements

- Journal entry text and metadata
- Entry date and timestamps
- Database connection information
- User or author metadata (when applicable)

## 🔎 Explore Your Database (Optional)

These exploration tasks are optional, but helpful for validation:

- Use `psql` or a database client to inspect tables and records.
- Use `kubectl exec` to query from a pod if the database is only accessible from the cluster.
- Check the schema after deployment and verify the expected tables exist.

## 🔧 Troubleshooting

Common issues and checks:

- Verify Azure CLI login and correct subscription.
- Confirm GitHub secrets are properly set.
- Ensure AKS has `AcrPull` access to ACR.
- Check the AKS authorized IP ranges for API server access.
- Validate PostgreSQL connectivity from AKS.
- Confirm Key Vault access policies allow AKS managed identity to get secrets.

## Manual Azure prerequisites

Before running automation, create or verify these Azure resources manually if they are not provisioned by Terraform yet:

1. **Azure Subscription**
2. **Azure Resource Group**
3. **Azure Container Registry (ACR)**
4. **Azure Kubernetes Service (AKS)**
5. **Azure Key Vault**
6. **Azure PostgreSQL Flexible Server**
7. **Service Principal or GitHub OIDC-enabled identity** for GitHub Actions

If you want Terraform to create all or part of these resources, inspect `infra-terraform/` and provide values for variables in your own `terraform.tfvars`.

## What files must be updated

### Terraform config
- `infra-terraform/variables.tf`
  - Provides variable definitions for Azure resources.
- `infra-terraform/main.tf`
  - Defines Resource Group, VNet, subnets, PostgreSQL, Key Vault ACLs, and AKS.
- `infra-terraform/aks.tf`
  - Defines the AKS cluster.
- `infra-terraform/acr.tf`
  - Defines ACR and the `AcrPull` role assignment for AKS.
- `infra-terraform/keyvault.tf`
  - Defines Key Vault, access policies, and a secret for PostgreSQL admin password.

### GitHub Actions
- `.github/workflows/app-ci.yml`
  - CI pipeline: lint, tests, build Docker image, scan, and push to ACR.
- `.github/workflows/app-cd.yml`
  - CD pipeline: deploys Kubernetes resources to AKS after successful CI.

### Kubernetes manifests
- `k8s-manifests/deployment.yaml`
  - Defines the app deployment and init container for DB setup.
- `k8s-manifests/service.yaml`
  - Exposes the application inside the AKS cluster.
- `k8s-manifests/hpa.yaml`
  - Optional Horizontal Pod Autoscaler.
- `k8s-manifests/secret.yaml.template`
  - Template for runtime database secrets.
- `k8s-manifests/configmap.yaml`
  - Application config map and DB init SQL script.

## Variables to update from manually created Azure resources

You need to update `terraform.tfvars` or pass these variables into Terraform:

- `subscription_id` - Azure subscription ID.
- `resource_group_name` - Resource Group name for deployment.
- `location` - Azure region where resources are deployed.
- `vnet_name` - Virtual Network name.
- `aks_cluster_name` - AKS cluster name.
- `postgres_server_name` - PostgreSQL server name.
- `postgres_admin_password` - PostgreSQL admin password.
- `key_vault_name` - Key Vault name.

If you deploy some resources manually, ensure the names and locations match the Terraform variables or use appropriate import commands.

## GitHub secrets and environment variables needed

The GitHub Actions workflows reference these secrets:

- `AZURE_CREDENTIALS`
  - JSON credentials for Azure login in GitHub Actions.
  - Typically created from a Service Principal with enough RBAC permissions.
- `ACR_NAME`
  - Name of the Azure Container Registry.
- `ACR_SERVER`
  - ACR login server, typically `<acrname>.azurecr.io`.
- `AKS_RESOURCE_GROUP`
  - Resource group containing the AKS cluster.
- `AKS_CLUSTER_NAME`
  - AKS cluster name.
- `POSTGRES_USER`
  - Database user to use in Kubernetes secret.
- `POSTGRES_PASSWORD`
  - Database password for Kubernetes secret.
- `POSTGRES_DB`
  - Database name used by the app.
- `POSTGRES_HOST`
  - PostgreSQL server hostname or FQDN.

### Optional / additional GitHub environment

The workflows also expect:

- `github.sha` and `github.event.workflow_run.head_sha`
  - Built-in GitHub variables used for image tags.

## Azure permissions required

### Service Principal / GitHub OIDC identity

The identity used by GitHub Actions must have permissions to:

- Login to Azure (`azure/login@v1` uses `AZURE_CREDENTIALS`).
- Read and push to ACR.
- Get AKS credentials and set context.
- Apply Kubernetes manifests via `kubectl`.
- Optionally deploy or manage infrastructure if using infra pipeline.

### AKS managed identity

AKS uses a system-assigned identity. Terraform grants this identity:

- `AcrPull` role assignment on the ACR resource.

### Key Vault permissions

The Key Vault setup contains:

- A Key Vault resource created by Terraform.
- A direct access policy for the current Azure client.
- A separate access policy granting AKS managed identity `Get` and `List` secret permissions.

### PostgreSQL access

The app expects a PostgreSQL server reachable from AKS. Network connectivity must allow AKS nodes to connect to the database.

## Key Vault secrets and keys in scope

The project currently manages one Key Vault secret in Terraform:

- `postgres-admin-password`

This secret is created from `var.postgres_admin_password` and stored in Key Vault.

> Note: The Kubernetes `secret.yaml.template` is not reading from Key Vault directly. The CD pipeline uses GitHub secrets and `envsubst` to render `POSTGRES_*` values into the Kubernetes secret manifest.

## What the pipelines do

### CI pipeline (`.github/workflows/app-ci.yml`)

The CI pipeline runs on pushes and pull requests affecting:
- `api/**`
- `k8s-manifests/**`
- `.github/workflows/app-ci.yml`

It performs:
- Checkout repository.
- Setup Python 3.13.
- Install dependencies from `api/requirements.txt`.
- Run `ruff` lint checks (non-blocking).
- Run `pytest -q` tests.
- Build a Docker image tagged with `${ACR_SERVER}/learningsteps-app:${github.sha}`.
- Scan the image with `trivy` for HIGH and CRITICAL vulnerabilities.
- Login to Azure via `azure/login@v1` using `AZURE_CREDENTIALS`.
- Login to ACR with `az acr login --name $ACR_NAME`.
- Push the image to ACR.

### CD pipeline (`.github/workflows/app-cd.yml`)

The CD pipeline runs after the CI workflow completes successfully and on manual dispatch.
It performs:
- Checkout repository.
- Login to Azure using `AZURE_CREDENTIALS`.
- Set AKS context using `AKS_RESOURCE_GROUP` and `AKS_CLUSTER_NAME`.
- Render `k8s-manifests/secret.yaml.template` from GitHub secrets.
- Render `k8s-manifests/deployment.yaml` with actual ACR server and image tag.
- Apply Kubernetes manifests:
  - `secret.yaml`
  - `configmap.yaml`
  - deployment manifest
  - service.yaml
  - `hpa.yaml` (if present)
- Restart the `learningsteps` deployment.
- Verify rollout status.

### Infrastructure pipeline (not fully in source)

This repo contains Terraform definitions under `infra-terraform/`. There is no complete infrastructure GitHub workflow shown here, but the Terraform code provisions:
- Azure Resource Group
- Virtual Network and subnets
- AKS cluster
- Azure Container Registry
- Azure Key Vault
- Azure PostgreSQL Flexible Server
- AKS-managed identity role assignment for ACR
- Key Vault access policies for AKS

If you add or use an infra pipeline, it should:
- Initialize Terraform
- Validate and plan the Terraform configuration
- Apply infrastructure changes safely
- Manage state securely, ideally in remote backend storage

## What is in scope for each pipeline

### CI
- Code quality checks.
- Unit tests and application test suite.
- Docker image build.
- Container image vulnerability scan.
- ACR image push.

### CD
- Kubernetes deployment to AKS.
- Secret and config injection for runtime environment.
- Rolling application updates.

### Infrastructure
- Azure resource provisioning and networking.
- Identity and permissions for AKS, ACR, and Key Vault.
- Database and Key Vault creation.

## What is out of scope

- Direct Key Vault secret retrieval from the application.
- Automatic database schema migration beyond the init container SQL script.
- Cluster monitoring stack installation (Prometheus, Grafana, Azure Monitor agent) in the current manifests.
- Full GitHub Actions infrastructure pipeline implementation.
- Production-grade secrets rotation or Key Vault-backed service identity injection.

## How to set this project up and deploy to Azure

### 1. Configure Azure resources manually or via Terraform

If you are provisioning manually, create the following resources first:

1. Resource Group.
2. Azure Container Registry.
3. AKS cluster with system-assigned managed identity.
4. Azure Key Vault.
5. PostgreSQL Flexible Server.

If using Terraform, place your values in `infra-terraform/terraform.tfvars` and run:

```bash
cd infra-terraform
target/terraform init
target/terraform plan
target/terraform apply -auto-approve
```

> Replace `target/` with the correct path if needed.

### 2. Set GitHub secrets

In your GitHub repository settings, set the following secrets:

- `AZURE_CREDENTIALS` - Azure service principal JSON.
- `ACR_NAME` - Registry name, e.g. `evolutionacrj`.
- `ACR_SERVER` - Login server, e.g. `evolutionacrj.azurecr.io`.
- `AKS_RESOURCE_GROUP` - Resource group name containing AKS.
- `AKS_CLUSTER_NAME` - AKS cluster name.
- `POSTGRES_USER` - Database user.
- `POSTGRES_PASSWORD` - Database password.
- `POSTGRES_DB` - Database name.
- `POSTGRES_HOST` - PostgreSQL host or FQDN.

### 3. Update manifest templates and config

- `k8s-manifests/secret.yaml.template`
  - This template renders database credentials and `DATABASE_URL`.
- `k8s-manifests/deployment.yaml`
  - Contains placeholders `<acr-server>` and `<acr_tag>` replaced by the CD workflow.
- `k8s-manifests/configmap.yaml`
  - Contains production app config and the DB schema initialization SQL script.

### 4. Run CI and CD pipelines

Once secrets are configured and code is pushed:

- The CI workflow will run automatically on `main` or matching PR paths.
- On successful CI completion, the CD workflow will deploy the app to AKS.
- You can also manually trigger CD via workflow dispatch.

## Monitoring and observability

The repository does not currently include a monitoring stack. Recommended next steps:

- Configure Azure Monitor for AKS.
- Enable Container insights for AKS.
- Use Azure Monitor metrics to track CPU, memory, and pod health.
- Add application logging to FastAPI and route logs to Azure Monitor or a centralized log platform.
- Add health probes and liveness/readiness checks for Kubernetes.

### Suggested monitoring configuration

1. Enable AKS monitoring during cluster creation or via the Azure Portal.
2. Link the AKS cluster to an Azure Log Analytics workspace.
3. Enable container insights.
4. Add application-level logging in `api/main.py`.
5. Use Kubernetes events and `kubectl rollout status` for deployment validation.

## Important security notes

- `infra-terraform/keyvault.tf` currently stores the PostgreSQL admin password as a Key Vault secret.
- GitHub Actions uses secrets for `AZURE_CREDENTIALS` and DB credentials. Do not store these values in version control.
- The CD workflow writes `secret.yaml` to the repo workspace during runtime; keep the generated file out of source control.
- Ensure `api_server_access_profile.authorized_ip_ranges` in `infra-terraform/aks.tf` is restricted to trusted IP ranges.

## Final summary

This project is a full-stack Azure deployment example for a Python FastAPI app using AKS, ACR, PostgreSQL, and Key Vault. The GitHub Actions workflows manage CI and CD, while Terraform contains the infrastructure definitions. `README2.md` is intended to document both the current automation and what needs to be configured to make the deployment work.
