# Incident Runbook: Pod CrashLoopBackOff

**Alert Name:** `KubePodCrashLooping`  
**Severity:** Critical  

---

## 1. Description
A container is continuously crashing, restarting, and entering an exponential backoff loop (`CrashLoopBackOff`), preventing normal traffic handling.

---

## 2. Common Root Causes
1. **Missing ConfigMap / Secret**: Application crashes on startup because an expected environment variable or secret key is missing.
2. **Database / Downstream Unreachable**: Failed connection timeout to Azure SQL, Cosmos DB, or Redis cache.
3. **Failing Liveness Probe**: Liveness probe endpoint returns 500 or exceeds timeout.
4. **Incorrect Entrypoint / Permissions**: Non-root container attempting to bind to privileged port (< 1024) or write to read-only filesystem.

---

## 3. Immediate Diagnostic Commands

### Step 1: Check Pod Logs of the Previous Crashed Container
```bash
kubectl logs <pod-name> -n <namespace> --previous --tail=100
```

### Step 2: Inspect Kubernetes Events
```bash
kubectl get events -n <namespace> --field-selector involvedObject.name=<pod-name> --sort-by='.lastTimestamp'
```

### Step 3: Verify Liveness & Readiness Probes
```bash
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.containers[*].livenessProbe}'
```
