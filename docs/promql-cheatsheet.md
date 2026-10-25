# Enterprise PromQL Cheat Sheet for SREs & DevOps

A curated collection of battle-tested PromQL queries for Kubernetes and cloud infrastructure monitoring.

---

## 1. Golden Signals

### Traffic (Requests per Second)
```promql
# Total RPS across all HTTP services
sum by (service) (rate(http_requests_total[5m]))
```

### Latency (Percentiles)
```promql
# P99 Request Latency
histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket[5m])) by (le))

# P50 Request Latency (Median)
histogram_quantile(0.50, sum(rate(http_request_duration_seconds_bucket[5m])) by (le))
```

### Errors (5xx Percentage)
```promql
# HTTP 5xx error rate percentage
(sum(rate(http_requests_total{status=~"5.."}[5m])) / sum(rate(http_requests_total[5m]))) * 100
```

### Saturation (Memory & CPU)
```promql
# Pod memory usage vs limit %
sum(container_memory_working_set_bytes{container!=""}) by (pod) 
/ sum(kube_pod_container_resource_limits{resource="memory"}) by (pod) * 100
```

---

## 2. Pod & Container Reliability

### CrashLoopBackOff Detection
```promql
# Restarts per minute > 1
rate(kube_pod_container_status_restarts_total[5m]) * 60 > 1
```

### OOMKilled Detection
```promql
kube_pod_container_status_terminated_reason{reason="OOMKilled"} > 0
```

### CPU CFS Throttling %
```promql
sum(increase(container_cpu_cfs_throttled_periods_total[5m])) by (container, pod)
/ sum(increase(container_cpu_cfs_periods_total[5m])) by (container, pod) * 100
```

---

## 3. Node & Infrastructure Capacity

### Disk Space Linear Depletion Prediction
```promql
# Predicts whether filesystem will fill up within the next 8 hours
(node_filesystem_free_bytes{fstype!~"tmpfs|fuse.lxcfs"} / node_filesystem_size_bytes{fstype!~"tmpfs|fuse.lxcfs"} < 0.20)
and (predict_linear(node_filesystem_free_bytes[4h], 8 * 3600) < 0)
```

### Unready Nodes
```promql
kube_node_status_condition{condition="Ready", status="true"} == 0
```
