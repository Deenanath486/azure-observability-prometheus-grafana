<div align="center">

# 📊 Enterprise Cloud Observability & SRE Toolkit

**Production Observability as Code on Azure: Managed Prometheus, Managed Grafana, SRE Golden Signals, PromQL Alerting, and Log Analytics KQL**  
*4 Golden Signals • Multi-Burn-Rate Error Budgets • Pre-built Grafana Dashboards • Incident Response Runbooks*

[![Observability CI](https://github.com/Deenanath486/azure-observability-prometheus-grafana/actions/workflows/observability-ci.yml/badge.svg)](https://github.com/Deenanath486/azure-observability-prometheus-grafana/actions/workflows/observability-ci.yml)
[![Prometheus](https://img.shields.io/badge/Prometheus-v2.51-E6522C?logo=prometheus&logoColor=white)](https://prometheus.io/)
[![Grafana](https://img.shields.io/badge/Grafana-v10-F46800?logo=grafana&logoColor=white)](https://grafana.com/)
[![Azure Monitor](https://img.shields.io/badge/Azure-Monitor-0078D4?logo=microsoftazure&logoColor=white)](https://azure.microsoft.com/services/monitor/)
[![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

</div>

---

## 📌 Architecture & Telemetry Pipeline

This repository implements an enterprise-grade **Observability & Site Reliability Engineering (SRE)** architecture across **Azure Kubernetes Service (AKS)** and Azure Cloud Infrastructure.

```
+-----------------------------------------------------------------------------------+
|                        Telemetry Sources (AKS & Azure Cloud)                      |
|                                                                                   |
|  +--------------------+     +---------------------+     +----------------------+  |
|  | Microservice Pods  |     |  Kubernetes Nodes   |     | Application Gateway  |  |
|  | (/metrics endpoint)|     |  (node-exporter)    |     |   (Ingress Access)   |  |
|  +---------+----------+     +----------+----------+     +----------+-----------+  |
+------------|---------------------------|---------------------------|--------------+
             |                           |                           |
             v                           v                           v
+-----------------------------------------------------------------------------------+
|                        Azure Monitor & Telemetry Ingestion                        |
|                                                                                   |
|   +------------------------------------+  +------------------------------------+  |
|   |  Azure Managed Prometheus (AMW)    |  |  Log Analytics Workspace (LAW)     |  |
|   |  • High-frequency metrics scrape   |  |  • Diagnostic logs & stdout/stderr |  |
|   |  • ServiceMonitors & PodMonitors   |  |  • ContainerLogV2 & KubeEvents     |  |
|   +------------------+-----------------+  +-----------------+------------------+  |
+----------------------|--------------------------------------|---------------------+
                       |                                      |
                       v                                      v
+-----------------------------------------------------------------------------------+
|                             Visualization & Analytics                             |
|                                                                                   |
|       +------------------------------------+     +-------------------------+      |
|       |     Azure Managed Grafana          |     | Log Analytics KQL Engine|      |
|       |  • AKS Capacity & Health           |     | • CrashLoop Diagnostics |      |
|       |  • SRE 4 Golden Signals            |     | • NSG Denied Flow Logs  |      |
|       |  • Host VM & Disk IOPS             |     | • FinOps Waste Audits   |      |
|       +-----------------+------------------+     +-------------------------+      |
+-------------------------|---------------------------------------------------------+
                          |
                          v
+-----------------------------------------------------------------------------------+
|                           Alerting & Incident Response                            |
|                                                                                   |
|     +-------------------------+        +------------------------------------+     |
|     |  Prometheus Alertmanager |------> | Microsoft Teams / Slack Webhook    |     |
|     |  • Multi-receiver routes|        | (Informational & Warning alerts)   |     |
|     |  • Inhibition rules     |        +------------------------------------+     |
|     |  • Custom card templates|        | PagerDuty / Azure Action Groups    |     |
|     +-------------------------+------> | (Critical On-Call pages)           |     |
|                                        +------------------------------------+     |
+-----------------------------------------------------------------------------------+
```

---

## 🎯 Google SRE 4 Golden Signals Coverage

| Signal | Metric / PromQL Implementation | Threshold & Alert |
| :--- | :--- | :--- |
| **Traffic** | `sum by (service) (rate(http_requests_total[5m]))` | Monitors sudden drop or traffic spikes |
| **Latency** | `histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket[5m])) by (le))` | P99 > 1500ms over 5m triggers Warning |
| **Errors** | `(sum(rate(http_requests_total{status=~"5.."}[5m])) / sum(rate(http_requests_total[5m]))) * 100` | 5xx error rate > 5% triggers Critical Page |
| **Saturation** | `sum(container_memory_working_set_bytes) / sum(kube_pod_container_resource_limits) * 100` | Memory > 90% triggers OOM prevention alert |

---

## 📂 Repository Directory Layout

```plaintext
azure-observability-prometheus-grafana/
├── .github/
│   └── workflows/
│       └── observability-ci.yml       # Promtool rules validation & Grafana JSON linting
├── alerting/
│   ├── alertmanager-config.yaml       # Multi-tier routing & node inhibition rules
│   ├── alert-templates.tmpl           # Custom MS Teams / Slack notification templates
│   └── azure-action-groups.tf         # Azure Monitor Action Groups (Email/Webhook)
├── dashboards/                        # Production Grafana Dashboard JSON definitions
│   ├── aks-cluster-capacity-health.json  # Node capacity, CPU/Mem saturation, crash stats
│   ├── microservices-four-golden-signals.json # SRE Traffic, Latency, Errors, Saturation
│   └── azure-vm-infrastructure.json   # Disk IOPS, network bandwidth, host metrics
├── k8s-monitoring/
│   ├── prometheus-rules/
│   │   ├── kubernetes-apps-alerts.yaml # Pod CrashLooping, OOMKilled, Replica mismatch
│   │   ├── kubernetes-nodes-alerts.yaml # NodeNotReady, DiskPressure, MemoryPressure
│   │   └── ingress-sli-alerts.yaml     # 5xx spikes, P99 latency breach
│   ├── servicemonitors/
│   │   ├── app-servicemonitor.yaml     # Application metric scraping spec
│   │   └── ingress-servicemonitor.yaml # Ingress controller scraping spec
│   └── podmonitors/
│       └── batch-job-podmonitor.yaml   # Short-lived batch workloads scraping
├── kql-queries/                       # Enterprise KQL Library for Log Analytics
│   ├── aks-container-diagnostics.kql  # OOMKilled events, crash logs, failed scheduling
│   ├── security-and-audit.kql         # NSG denied flow logs, RBAC changes, Key Vault
│   ├── performance-and-latency.kql    # App Gateway 5xx, high-latency API endpoints
│   └── finops-compute-utilization.kql # Underutilized CPU/Memory node detection
├── infra/                             # Terraform IaC for Observability Stack
│   ├── main.tf                        # Azure Monitor Workspace, Managed Grafana, LAW
│   ├── variables.tf                   # Environment & retention configurations
│   ├── outputs.tf                     # Workspace IDs & Grafana endpoints
│   └── terraform.tfvars.example       # Sample production variables
└── docs/                              # Engineering documentation & operational guides
    ├── promql-cheatsheet.md           # Curated PromQL queries for daily operations
    ├── sli-slo-error-budgets.md       # Multi-window multi-burn-rate alerting guide
    └── incident-runbooks/
        ├── runbook-oomkilled.md       # Exit Code 137 triage and remediation
        ├── runbook-crashloopbackoff.md# Application restart loop investigation
        └── runbook-nodenotready.md    # Cluster node failure and drain runbook
```

---

## 🚀 Quickstart: Deploying the Observability Stack

### 1. Provision Infrastructure via Terraform

```bash
cd infra
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

### 2. Apply Custom Prometheus Alerting Rules to AKS

```bash
# Apply Prometheus Rules
kubectl apply -f k8s-monitoring/prometheus-rules/

# Apply ServiceMonitors
kubectl apply -f k8s-monitoring/servicemonitors/
```

### 3. Import Grafana Dashboards

1. Navigate to your Azure Managed Grafana portal (`outputs.grafana_endpoint`).
2. Go to **Dashboards ➔ Import**.
3. Upload any of the pre-configured JSON files from `dashboards/`:
   - `aks-cluster-capacity-health.json`
   - `microservices-four-golden-signals.json`
   - `azure-vm-infrastructure.json`

---

## 👤 Author & Maintainer

**Deenanath Yadav**  
*Senior DevOps / DevSecOps Engineer & Azure Cloud Architect*  
- **GitHub**: [@Deenanath486](https://github.com/Deenanath486)  
- **LinkedIn**: [linkedin.com/in/deenanath-yadav-08b265147](https://www.linkedin.com/in/deenanath-yadav-08b265147/)  
- **Email**: deenanath.yadav@hotmail.com  

---

<div align="center">
⭐ Star this repository if you find this Observability toolkit valuable!
</div>
