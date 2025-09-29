# Complete Local Kubernetes Platform Deployment Guide

## 🎯 Overview

This guide provides step-by-step instructions to deploy a complete Local Kubernetes Platform with GitOps, Istio, Observability, and Microservices. Everything is tested and working on Windows with PowerShell.

## 📋 Prerequisites

### Required Software
- **Docker Desktop** (with Kubernetes enabled)
- **kubectl** (Kubernetes CLI)
- **Helm 3.x**
- **Git**
- **PowerShell** (Windows)

### Installation Commands
```powershell
# Install kubectl
choco install kubernetes-cli

# Install Helm
choco install kubernetes-helm

# Install Git
choco install git
```

## 🚀 Quick Start (One-Command Deployment)

```powershell
# Clone the repository
git clone https://github.com/Bhavesh1326/case-study.git
cd case-study

# Deploy everything
.\scripts\deploy.ps1
```

## 📁 Project Structure

```
case-study/
├── .github/workflows/          # CI/CD pipeline
├── argocd/applications/        # GitOps applications
├── docs/                       # Documentation
├── istio/config/              # Service mesh configuration
├── manifests/                 # Kubernetes manifests
├── microservices/manifests/   # Sample microservices
├── observability/manifests/   # Monitoring stack
├── scripts/                   # Deployment scripts
└── security/manifests/        # Security tools
```

## 🔧 Manual Deployment Steps

### Step 1: Verify Prerequisites
```powershell
# Check Docker
docker --version

# Check kubectl
kubectl version --client

# Check Helm
helm version

# Check Kubernetes cluster
kubectl cluster-info
```

### Step 2: Create Namespaces
```powershell
kubectl apply -f manifests/namespace.yaml
```

### Step 3: Install Istio Service Mesh
```powershell
# Download Istio
curl -L https://istio.io/downloadIstio | sh -
$env:PATH += ";$PWD\istio-*\bin"

# Install Istio
istioctl install --set values.defaultRevision=default -y

# Enable sidecar injection
kubectl label namespace microservices istio-injection=enabled --overwrite
kubectl label namespace observability istio-injection=enabled --overwrite

# Apply Istio configuration
kubectl apply -f istio/config/
```

### Step 4: Install Argo CD (GitOps)
```powershell
# Add Helm repository
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# Install Argo CD
helm upgrade --install argocd argo/argo-cd `
  --namespace argocd `
  --set server.service.type=NodePort `
  --set server.service.nodePortHttp=30080 `
  --set server.extraArgs[0]="--insecure" `
  --wait
```

### Step 5: Install Observability Stack
```powershell
# Add Helm repositories
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add jaegertracing https://jaegertracing.github.io/helm-charts
helm repo update

# Install Prometheus Stack
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack `
  --namespace observability `
  --values observability/manifests/prometheus-values.yaml `
  --wait

# Install Jaeger
helm upgrade --install jaeger jaegertracing/jaeger `
  --namespace observability `
  --values observability/manifests/jaeger-values.yaml `
  --wait
```

### Step 6: Install Security Tools
```powershell
# Add Helm repositories
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo add gatekeeper https://open-policy-agent.github.io/gatekeeper/charts
helm repo update

# Install Falco
helm upgrade --install falco falcosecurity/falco `
  --namespace security `
  --values security/manifests/falco-values.yaml `
  --wait

# Install OPA Gatekeeper
helm upgrade --install gatekeeper gatekeeper/gatekeeper `
  --namespace security `
  --wait

# Apply Gatekeeper policies
kubectl apply -f security/manifests/opa-gatekeeper-policies.yaml
```

### Step 7: Deploy Microservices
```powershell
# Deploy microservices
kubectl apply -f microservices/manifests/ -R

# Apply network policies
kubectl apply -f manifests/network-policies.yaml
```

### Step 8: Setup Argo CD Applications
```powershell
# Apply Argo CD applications
kubectl apply -f argocd/applications/ -R
```

## 🌐 Access Services

### Port-Forward Setup
```powershell
# Frontend
kubectl port-forward -n microservices svc/frontend 8081:80

# Backend API
kubectl port-forward -n microservices svc/backend 8080:8080

# Argo CD
kubectl port-forward -n argocd svc/argocd-server 30080:80

# Grafana
kubectl port-forward -n observability svc/prometheus-grafana 30300:80

# Jaeger
kubectl port-forward -n observability svc/jaeger-query 30686:16686

# Prometheus
kubectl port-forward -n observability svc/prometheus-kube-prometheus-prometheus 30900:9090

# Loki
kubectl port-forward -n observability svc/loki 3100:3100
```

### Service Access URLs

| Service | URL | Login Credentials |
|---------|-----|-------------------|
| **Frontend Demo** | http://localhost:8081 | - |
| **Backend API** | http://localhost:8080/health | - |
| **Argo CD** | http://localhost:30080 | admin / DO5UrMN5uga-RUjn |
| **Grafana** | http://localhost:30300 | admin / admin123 |
| **Jaeger** | http://localhost:30686 | - |
| **Prometheus** | http://localhost:30900 | - |
| **Loki** | http://localhost:3100 | - |

## 🧪 Testing the Platform

### 1. Test Frontend Application
```powershell
# Open browser to http://localhost:8081
# Click "Check Backend Status" button
# Should show "Healthy" status
```

### 2. Test Backend API
```powershell
# Test health endpoint
curl http://localhost:8080/health

# Test users endpoint
curl http://localhost:8080/api/users

# Test status endpoint
curl http://localhost:8080/api/status
```

### 3. Test Argo CD
```powershell
# Open browser to http://localhost:30080
# Login with admin / DO5UrMN5uga-RUjn
# Should see platform-app and microservices-app
```

### 4. Test Grafana Dashboards
```powershell
# Open browser to http://localhost:30300
# Login with admin / admin123
# Browse dashboards:
# - Kubernetes Cluster Overview
# - Istio Service Dashboard
# - Istio Workload Dashboard
```

### 5. Test Jaeger Tracing
```powershell
# Open browser to http://localhost:30686
# Look for traces from microservices
# Should see request flows through Istio
```

### 6. Test Prometheus Metrics
```powershell
# Open browser to http://localhost:30900
# Try these queries:
# - istio_requests_total
# - up{job="kubernetes-pods"}
# - kube_pod_info
```

## 📊 Generate Traffic for Monitoring

### Automated Traffic Generation
```powershell
# Run traffic generation script
.\scripts\generate-traffic.ps1
```

### Manual Traffic Generation
1. Open multiple browser tabs to http://localhost:8081
2. Click "Check Backend Status" repeatedly
3. Refresh the page multiple times
4. Open http://localhost:8080/health and refresh

## 🔍 Verification Commands

### Check Pod Status
```powershell
# All pods
kubectl get pods --all-namespaces

# Microservices pods
kubectl get pods -n microservices

# Observability pods
kubectl get pods -n observability

# Istio pods
kubectl get pods -n istio-system
```

### Check Services
```powershell
# All services
kubectl get svc --all-namespaces

# NodePort services
kubectl get svc --all-namespaces | findstr NodePort
```

### Check Istio Configuration
```powershell
# Istio gateways and virtual services
kubectl get gateway,virtualservice -n istio-system

# Istio sidecar injection status
kubectl get pods -n microservices -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[*].name}{"\n"}{end}'
```

### Check Argo CD Applications
```powershell
# Argo CD applications
kubectl get applications -n argocd

# Application status
kubectl describe application platform-app -n argocd
kubectl describe application microservices-app -n argocd
```

## 🛠️ Troubleshooting

### Common Issues and Solutions

#### 1. Pods Stuck in Pending
```powershell
# Check node resources
kubectl describe nodes

# Check storage classes
kubectl get storageclass

# Check PVC status
kubectl get pvc --all-namespaces
```

#### 2. Port-Forward Issues
```powershell
# Check if ports are in use
netstat -an | findstr :8081

# Kill existing port-forwards
taskkill /f /im kubectl.exe

# Restart port-forwards
kubectl port-forward -n microservices svc/frontend 8081:80
```

#### 3. Backend API Not Working
```powershell
# Check backend pod logs
kubectl logs -n microservices deployment/backend

# Check backend pod status
kubectl get pods -n microservices -l app=backend

# Restart backend deployment
kubectl rollout restart deployment/backend -n microservices
```

#### 4. Grafana Dashboards Empty
```powershell
# Generate traffic first
.\scripts\generate-traffic.ps1

# Check Prometheus targets
# Open http://localhost:30900/targets

# Check if metrics are being collected
curl "http://localhost:30900/api/v1/query?query=istio_requests_total"
```

## 🧹 Cleanup

### Remove All Components
```powershell
# Run cleanup script
.\scripts\cleanup.ps1

# Or manual cleanup
kubectl delete applications --all -n argocd
kubectl delete -f microservices/manifests/ -R
helm uninstall prometheus -n observability
helm uninstall jaeger -n observability
helm uninstall falco -n security
helm uninstall gatekeeper -n security
helm uninstall argocd -n argocd
istioctl uninstall --purge -y
kubectl delete namespace argocd istio-system observability microservices security
```

## 📚 Additional Resources

### Key Files
- **Deployment Script**: `scripts/deploy.ps1`
- **Cleanup Script**: `scripts/cleanup.ps1`
- **Traffic Generation**: `scripts/generate-traffic.ps1`
- **Prometheus Config**: `observability/manifests/prometheus-values.yaml`
- **Istio Config**: `istio/config/`
- **Microservices**: `microservices/manifests/`

### Useful Commands
```powershell
# Get Argo CD password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($password))

# Check all port-forwards
Get-NetTCPConnection | Where-Object {$_.LocalPort -in @(8081,8080,30080,30300,30686,30900,3100)}

# View pod logs
kubectl logs -n microservices deployment/frontend
kubectl logs -n microservices deployment/backend
```

## 🎯 Success Criteria

Your platform is working correctly when:
- ✅ All pods show "Running" status
- ✅ Frontend loads at http://localhost:8081
- ✅ Backend API responds at http://localhost:8080/health
- ✅ Argo CD shows applications as "Synced" and "Healthy"
- ✅ Grafana dashboards show metrics data
- ✅ Jaeger shows traces from microservices
- ✅ Prometheus collects Istio metrics
- ✅ All port-forwards are active

## 🚀 Next Steps

1. **Customize Dashboards**: Add your own Grafana dashboards
2. **Add More Microservices**: Deploy additional services
3. **Configure Alerts**: Set up Prometheus alerting rules
4. **Security Hardening**: Implement additional security policies
5. **CI/CD Integration**: Connect with your Git repository

---

**Your Local Kubernetes Platform with GitOps, Istio, Observability, and Microservices is now fully operational! 🎉**
