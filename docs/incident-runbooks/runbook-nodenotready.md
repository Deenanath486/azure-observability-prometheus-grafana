# Incident Runbook: AKS Node NotReady

**Alert Name:** `KubeNodeNotReady`  
**Severity:** Critical  

---

## 1. Description
The Kubernetes control plane stopped receiving heartbeats from the node kubelet, or the node condition `Ready` transitioned to `False` or `Unknown`.

---

## 2. Immediate Diagnostic Checklist

### Step 1: Check Node Status and Conditions
```bash
kubectl describe node <node-name>
```
Look for:
- `NetworkUnavailable: True` (CNI routing or IP allocation failure)
- `DiskPressure: True` (Node root or container image disk full)
- `MemoryPressure: True` (System daemon out of memory)

### Step 2: Cordon & Drain the Unhealthy Node
To prevent newly scheduled pods from landing on the degraded node:
```bash
kubectl cordon <node-name>
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data --force
```

### Step 3: Trigger Azure AKS Node Repair
If using AKS Managed Node Auto-repair:
```bash
az aks nodepool restart --resource-group <rg-name> --cluster-name <aks-name> --nodepool-name <pool-name>
```
