# Incident Runbook: Container OOMKilled (Exit Code 137)

**Alert Name:** `KubeContainerOOMKilled`  
**Severity:** Critical  

---

## 1. Description
The Linux kernel killed the container process because memory consumption exceeded the declared `resources.limits.memory` in the pod specification, or the host node was critically low on free memory.

---

## 2. Triage & Investigation Steps

### Step 1: Confirm Termination Reason
```bash
kubectl describe pod <pod-name> -n <namespace>
```
Look for:
```text
Last State:     Terminated
  Reason:       OOMKilled
  Exit Code:    137
```

### Step 2: Check Recent Memory Consumption Trends
Run in Prometheus / Grafana:
```promql
container_memory_working_set_bytes{pod="<pod-name>", namespace="<namespace>"}
```

### Step 3: Identify Memory Leak vs Undersizing
- If memory grew steadily over hours without plateauing: **Memory Leak** (Application code bug, unclosed database connection pools, caching without eviction).
- If memory spiked suddenly during a batch processing task or high traffic surge: **Undersized Limits**.

---

## 3. Remediation & Mitigation

1. **Immediate Hotfix**: Increment memory limit in git overlay:
   ```yaml
   resources:
     limits:
       memory: "1Gi" # Increased from 512Mi
   ```
2. **Apply via GitOps**: Commit and push to Git repository for ArgoCD to sync.
3. **Profiling**: Capture heap dump or memory profile if leak is suspected.
