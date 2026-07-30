# System Technical Documentation: `ODINSLAYER09/learningsteps`

## Executive Overview & System Architecture

The **`ODINSLAYER09/learningsteps`** platform is an enterprise-grade, cloud-native microservices application designed for automated deployment, elastic scaling, robust security, and end-to-end observability on **Microsoft Azure**. The system implements modern DevOps and Infrastructure-as-Code (IaC) practices using **Terraform**, **Azure Kubernetes Service (AKS)**, **Azure Container Registry (ACR)**, **Azure Key Vault**, **GitHub Actions**, **Prometheus**, and **Grafana**.

### Core Architecture Diagram

```text
+---------------------------------------------------------------------------------------+
|                                    GITHUB REPOSITORY                                  |
|                      (Codebase, Manifests & Gitleaks Scan)                            |
+------------------------------------------+--------------------------------------------+
                                           |
                                GitHub Actions Workflows
                                           |
           +-------------------------------+-------------------------------+
           |                               |                               |
           v                               v                               v
+---------------------+         +---------------------+         +---------------------+
| infra-pipeline.yml  |         |     app-ci.yml      |         |     app-cd.yml      |
| (Terraform Apply)   |         | (Build & Push Docker|         |  (Deploy Manifests  |
|                     |         |  to Azure Registry) |         |     to AKS)         |
+----------+----------+         +----------+----------+         +----------+----------+
           |                               |                               |
           +-------------------------------+-------------------------------+
                                           |
                                           v
+---------------------------------------------------------------------------------------+
|                              AZURE CLOUD INFRASTRUCTURE                               |
|                                                                                       |
|  +--------------------+    +-----------------------+    +--------------------------+  |
|  | Resource Group     |    | Container Registry    |    | Key Vault                |  |
|  | (evolution-rg-j)   |    | (evolutionacrj)       |    | (evolution-kv)           |  |
|  +--------------------+    +-----------+-----------+    +------------+-------------+  |
|                                        |                             |                |
|                                        | Pull Image                  | Secrets        |
|                                        v                             v                |
|  +---------------------------------------------------------------------------------+  |
|  |                   Azure Kubernetes Service (learningsteps-aks)                  |  |
|  |                                                                                 |  |
|  |  [ Namespace: default ]                                                         |  |
|  |  +----------------------+   +-------------------+   +------------------------+  |  |
|  |  | FastAPI App Pods     |-->| PostgreSQL DB Pod |<--| K8s ConfigMap/Secret   |  |  |
|  |  | (Scalable via HPA)   |   | (Persistent Vol)  |   | (Injected at Runtime)   |  |  |
|  |  +----------+-----------+   +-------------------+   +------------------------+  |  |
|  |             |                                                                   |  |
|  |             v Exposes /metrics                                                  |  |
|  |  [ Namespace: monitoring ]                                                      |  |
|  |  +---------------------------------------------------------------------------+  |  |
|  |  | Prometheus Operator (ServiceMonitor) ===> Grafana Dashboards              |  |  |
|  |  +---------------------------------------------------------------------------+  |  |
|  +---------------------------------------------------------------------------------+  |
+---------------------------------------------------------------------------------------+
```

---

## Technical Features & Application Scope

| Feature Category | Technical Specifications & Capabilities |
| :--- | :--- |
| **Backend API** | Python 3.11+ / FastAPI, Uvicorn ASGI Server, RESTful endpoints (`/`, `/health`, `/items`, `/metrics`). |
| **Database Tier** | PostgreSQL 15, SQLAlchemy / asyncpg ORM drivers, automated schema migration and initialization. |
| **Containerization** | Multi-stage Docker build, lightweight Alpine base image, non-root application execution context. |
| **Infrastructure-as-Code** | Modularized HashiCorp Terraform (`azurerm` provider v3/v4), remote Azure Blob Storage backend. |
| **Kubernetes Orchestration** | AKS managed cluster, Horizontal Pod Autoscaler (HPA), LoadBalancer service, ConfigMaps, Secrets. |
| **Security & Secrets** | Azure Key Vault for secrets storage, Gitleaks commit scanning, Azure RBAC Service Principal roles. |
| **Observability Stack** | `prometheus-fastapi-instrumentator`, Prometheus Operator, ServiceMonitor CRD, Grafana Dashboard. |

---

## Detailed Pipeline Analysis (In-Scope vs Out-of-Scope)

### Pipeline Responsibilities Matrix

| Pipeline File | In-Scope Operations | Out-of-Scope Operations | Test Execution |
| :--- | :--- | :--- | :--- |
| **`infra-pipeline.yml`** | Provision Resource Group, ACR, AKS, Key Vault, PostgreSQL, Subnets, and Role Assignments. | Application Docker builds, Kubernetes deployment manifests, application secrets injection. | Terraform syntax linting, `trivy` security scan on `.tf` files. |
| **`app-ci.yml`** | Run Python unit/integration tests, build multi-stage Docker image, authenticate via `az acr login`, push image to ACR tagged with `GITHUB_SHA`. | Infra provisioning, cluster deployment, secret creation in Azure Key Vault. | Pytest suite (`pytest tests/`), Docker build validation, Gitleaks secret scan. |
| **`app-cd.yml`** | Fetch cluster credentials via `az aks get-credentials`, substitute image tags, apply `k8s-manifests/` using `kubectl`. | Database schema creation, cloud infrastructure alterations, Docker image building. | Rollout validation (`kubectl rollout status deployment/learningsteps-app`). |

---

## Azure Setup & Prerequisites Guide

### 1. Manual Steps Required in Azure First
Before executing any automated pipeline, the bootstrapping environment must be created manually in Azure:

1. **Azure Subscription & Tenant:** Access to an active Azure Subscription.
2. **Storage Account for Terraform State:**
   * Resource Group: `rg-tfstate-bootstrap`
   * Storage Account: `stlearningstepstfstate` (globally unique)
   * Blob Container: `tfstate`
3. **Azure AD / Entra ID Service Principal:**
   * Create Service Principal with Contributor scope on the Subscription:
     ```bash
     az ad sp create-for-rbac        --name "sp-learningsteps-github"        --role "Contributor"        --scopes /subscriptions/<AZURE_SUBSCRIPTION_ID>        --sdk-auth
     ```
   * Assign **User Access Administrator** (or **Role Based Access Control Administrator**) on the target Resource Group (`evolution-rg-j`) to allow Terraform to delegate `AcrPull` role assignments between AKS and ACR.

### 2. GitHub Secrets Configuration Table

Configure the following repository secrets under **Settings -> Secrets and variables -> Actions**:

| Secret Key Name | Required Format / Description | Example / Value |
| :--- | :--- | :--- |
| `AZURE_CREDENTIALS` | Entire JSON output from `az ad sp create-for-rbac` command. | `{"clientId": "...", "clientSecret": "...", "subscriptionId": "...", "tenantId": "..."}` |
| `AZURE_CLIENT_ID` | Service Principal Client (Application) ID GUID. | `44f357b8-8232-4bba-a5bf-081ba7a41eb1` |
| `AZURE_CLIENT_SECRET` | Service Principal authentication password/secret. | `wX8~...` |
| `AZURE_SUBSCRIPTION_ID` | Azure Subscription GUID. | `6a9a0ca4-d17c-4caf-a4d5-25747d82995c` |
| `AZURE_TENANT_ID` | Azure Active Directory Tenant GUID. | `c0531484-50fa-4ff2-97df-b1f2d4810603` |
| `ACR_NAME` | Azure Container Registry resource name. | `evolutionacrj` |
| `ACR_SERVER` | Azure Container Registry login server. | `evolutionacrj.azurecr.io` |
| `AKS_CLUSTER_NAME` | Azure Kubernetes Service cluster name. | `learningsteps-aks` |
| `RESOURCE_GROUP` | Primary Azure Resource Group name. | `evolution-rg-j` |

### 3. Azure Key Vault Secrets Configuration

The following keys **must** exist inside `evolution-kv` Key Vault:

* `postgres-admin-password`: Database superuser administrative password.
* `postgres-user-password`: Application runtime database password.
* `api-secret-key`: JWT/API authentication signature secret.

---

## Database Schema & Test Data Specifications

### Expected Database Schema

The PostgreSQL database maintains the primary application tables:

```sql
-- Database Initialization Script (database/init.sql)

CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS items (
    id SERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    price NUMERIC(10, 2) NOT NULL,
    owner_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

### Initial Test Data

```sql
INSERT INTO users (username, email) VALUES
('alice_dev', 'alice@example.com'),
('bob_ops', 'bob@example.com')
ON CONFLICT DO NOTHING;

INSERT INTO items (title, description, price, owner_id) VALUES
('Cloud Handbook', 'Guide to Azure Kubernetes Service', 49.99, 1),
('DevOps Pipeline Script', 'Automated GitHub Actions workflow template', 19.99, 2)
ON CONFLICT DO NOTHING;
```

---

## Monitoring & Observability Implementation

### 1. Application Metrics Instrumentation (`api/main.py`)

The FastAPI application uses `prometheus-fastapi-instrumentator` to track HTTP metrics:

```python
from fastapi import FastAPI
from prometheus_fastapi_instrumentator import Instrumentator

app = FastAPI(title="learningsteps API")

# Initialize and expose /metrics endpoint
Instrumentator().instrument(app).expose(app)

@app.get("/health")
def health_check():
    return {"status": "healthy", "database": "connected"}
```

### 2. Deploying Prometheus & Grafana Stack

Run the automated setup script (`monitoring/monitoring-setup.sh`):

```bash
#!/usr/bin/env bash
set -e

echo "Installing Prometheus Community Helm Repository..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

echo "Creating monitoring namespace..."
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

echo "Deploying kube-prometheus-stack..."
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack   --namespace monitoring   --set grafana.adminPassword="AdminSecurePassword123!"   --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false
```

### 3. ServiceMonitor Configuration (`monitoring/servicemonitor.yaml`)

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: fastapi-servicemonitor
  namespace: monitoring
  labels:
    release: prometheus
spec:
  selector:
    matchLabels:
      app: learningsteps-api
  namespaceSelector:
    matchNames:
      - default
  endpoints:
    - port: http
      path: /metrics
      interval: 15s
```

### 4. PromQL Queries for Grafana Dashboard

| Metric Panel Title | PromQL Query Expression | Visualization Type |
| :--- | :--- | :--- |
| **HTTP Request Rate (RPS)** | `sum(rate(http_requests_total[5m])) by (handler, status)` | Time Series Line Graph |
| **API Latency (95th Percentile)** | `histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (le))` | Gauge / Line Graph |
| **Application Up Status** | `up{job="learningsteps-api"}` | Stat / Status History |
| **Database Active Connections** | `pg_stat_activity_count` | Single Stat Card |

---

## Application & Observability Access Endpoints

| Component | Access Protocol & Command / URL | Credentials / Notes |
| :--- | :--- | :--- |
| **Public API Application** | `http://<AKS_LOADBALANCER_IP>/docs` | FastAPI Swagger Interactive UI. |
| **Grafana Dashboard** | `kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring` | Username: `admin`<br>Password: `AdminSecurePassword123!` |
| **Prometheus UI** | `kubectl port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090 -n monitoring` | Raw PromQL metric inspection interface. |
| **PostgreSQL Database** | `kubectl port-forward svc/postgres-service 5432:5432` | Host: `127.0.0.1`, Port: `5432`<br>User: `postgres` |
