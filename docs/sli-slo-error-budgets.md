# SRE Framework: SLIs, SLOs, and Error Budgets

This document outlines the Site Reliability Engineering (SRE) standard adopted for modern cloud-native applications on Azure Kubernetes Service.

---

## 1. Core Terminology

- **SLI (Service Level Indicator)**: A carefully defined quantitative measure of some aspect of the level of service that is provided (e.g. Request Latency, Error Rate).
- **SLO (Service Level Objective)**: A target value or range of values for a service level that is measured by an SLI (e.g. 99.9% of requests succeed).
- **SLA (Service Level Agreement)**: An explicit or implicit contract with end users that includes consequences of meeting (or missing) the SLOs.
- **Error Budget**: The room for failure over a given window ($100\% - \text{SLO}$). For a 99.9% SLO over 30 days, the error budget is 0.1% (approx. 43.2 minutes of total downtime).

---

## 2. Defining Multi-Window Multi-Burn-Rate Alerts

Rather than triggering alerts on temporary blips, production SRE systems trigger pages based on the rate at which the Error Budget is consumed:

| Burn Rate | % Error Budget Consumed | Time to 100% Depletion | Window 1 (Long) | Window 2 (Short) | Severity |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **14.4x** | 2% | 2 days | 1 hour | 5 minutes | **Critical (Page On-Call)** |
| **6x** | 5% | 5 days | 6 hours | 30 minutes | **Critical (Page On-Call)** |
| **1x** | 10% | 30 days | 3 days | 6 hours | **Warning (Ticket / Slack)** |

---

## 3. PromQL Implementation Example for Multi-Burn-Rate

```promql
# 1-hour burn rate > 14.4 (burning 2% of 30-day budget in 1 hour)
(
  sum(rate(http_requests_total{status=~"5.."}[1h]))
  /
  sum(rate(http_requests_total[1h]))
) > (1 - 0.999) * 14.4
and
(
  sum(rate(http_requests_total{status=~"5.."}[5m]))
  /
  sum(rate(http_requests_total[5m]))
) > (1 - 0.999) * 14.4
```
