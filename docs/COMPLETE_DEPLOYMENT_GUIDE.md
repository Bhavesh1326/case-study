# Complete Kubernetes Platform Deployment Guide

## 🎯 Project Overview
This guide will help you deploy a complete Kubernetes platform with:
- **GitOps** with Argo CD
- **Service Mesh** with Istio
- **Observability Stack** (Prometheus, Grafana, Loki, Jaeger)
- **Microservices** (Frontend, Backend, Database)
- **Security Tools** (Falco, OPA Gatekeeper)

## 📋 Prerequisites

### Required Software
1. **Docker Desktop** - Must be running
2. **Kubernetes Cluster** - One of these:
   - Minikube
   - Kind (Kubernetes in Docker)
   - Docker Desktop Kubernetes
3. **kubectl** - Kubernetes command-line tool
4. **Helm** - Package manager for Kubernetes
5. **Git** - Version control

### System Requirements
- **OS**: Windows 10/11, macOS, or Linux
- **RAM**: Minimum 8GB (16GB recommended)
- **CPU**: 4+ cores recommended
- **Storage**: 20GB free space

## 🚀 Step-by-Step Deployment

### Step 1: Clone the Repository
```bash
git clone https://github.com/Bhavesh1326/case-study.git
cd case-study
```

### Step 2: Setup Kubernetes Cluster

#### Option A: Using Minikube
```bash
# Start minikube
minikube start --memory=8192 --cpus=4

# Enable required addons
minikube addons enable metrics-server
minikube addons enable ingress
```

#### Option B: Using Kind
```bash
# Create kind cluster
kind create cluster --config=kind-config.yaml
```

#### Option C: Using Docker Desktop
1. Open Docker Desktop
2. Go to Settings → Kubernetes
3. Enable Kubernetes
4. Click "Apply & Restart"

### Step 3: Verify Cluster Setup
```bash
# Check cluster status
kubectl get nodes

# Check if cluster is ready
kubectl get pods --all-namespaces
```

### Step 4: Install Helm (if not already installed)

#### Windows (PowerShell)
```powershell
# Install via Chocolatey
choco install kubernetes-helm

# Or download from GitHub releases
# https://github.com/helm/helm/releases
```

#### macOS
```bash
# Install via Homebrew
brew install helm
```

#### Linux
```bash
# Install via script
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

### Step 5: Deploy the Platform

#### For Windows Users
```powershell
# Run the PowerShell deployment script
.\scripts\deploy.ps1
```

#### For Linux/macOS Users
```bash
# Make script executable
chmod +x scripts/deploy.sh

# Run the deployment script
./scripts/deploy.sh
```

### Step 6: Wait for Deployment
The deployment process takes 5-10 minutes. Monitor progress with:
```bash
# Check all pods
kubectl get pods --all-namespaces

# Check specific namespaces
kubectl get pods -n argocd
kubectl get pods -n observability
kubectl get pods -n microservices
kubectl get pods -n istio-system
```

## 🔧 Port Forwarding Setup

### Required Port Forwards
You need to run these commands in separate terminal windows:

#### Terminal 1: Frontend
```bash
kubectl port-forward -n microservices svc/frontend 8081:80
```

#### Terminal 2: Backend API
```bash
kubectl port-forward -n microservices svc/backend 8080:8080
```

#### Terminal 3: Argo CD
```bash
kubectl port-forward -n argocd svc/argocd-server 30080:80
```

#### Terminal 4: Grafana
```bash
kubectl port-forward -n observability svc/prometheus-grafana 30300:80
```

#### Terminal 5: Jaeger
```bash
kubectl port-forward -n observability svc/jaeger-query 30686:16686
```

#### Terminal 6: Prometheus
```bash
kubectl port-forward -n observability svc/prometheus-kube-prometheus-prometheus 30900:9090
```

#### Terminal 7: Loki
```bash
kubectl port-forward -n observability svc/loki 3100:3100
```

## 🔐 Access Credentials

### Argo CD
- **URL**: http://localhost:30080
- **Username**: admin
- **Password**: Get with this command:
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
```

### Grafana
- **URL**: http://localhost:30300
- **Username**: admin
- **Password**: admin123

### Jaeger
- **URL**: http://localhost:30686
- **No authentication required**

### Prometheus
- **URL**: http://localhost:30900
- **No authentication required**

### Loki
- **URL**: http://localhost:3100
- **No authentication required**

## 🧪 Testing the Platform

### 1. Test Frontend
- **URL**: http://localhost:8081
- **Expected**: Microservices demo page with green "Healthy" status
- **Features**: 
  - Click "Check Backend Status" button
  - Should show "Healthy" status

### 2. Test Backend API
- **Health Check**: http://localhost:8080/health
- **Users API**: http://localhost:8080/api/users
- **Status API**: http://localhost:8080/api/status
- **Expected**: JSON responses with service information

### 3. Test Argo CD (GitOps)
- **URL**: http://localhost:30080
- **Login**: admin / [password from command above]
- **Check**: 
  - platform-app should be "Synced" and "Healthy"
  - microservices-app should be "Synced" and "Healthy"

### 4. Test Grafana (Monitoring)
- **URL**: http://localhost:30300
- **Login**: admin / admin123
- **Dashboards to check**:
  - Kubernetes Cluster Dashboard
  - Istio Service Dashboard
  - Istio Workload Dashboard

### 5. Test Jaeger (Tracing)
- **URL**: http://localhost:30686
- **Check**: Look for traces from microservices
- **Note**: Traces appear after generating traffic

### 6. Test Prometheus (Metrics)
- **URL**: http://localhost:30900
- **Try queries**:
  - `up` - Shows all targets
  - `istio_requests_total` - Shows Istio metrics
  - `kubernetes_pod_info` - Shows pod information

### 7. Test Loki (Logs)
- **URL**: http://localhost:3100
- **Note**: May show 404 for some paths, but service is running

## 🚦 Generate Traffic for Dashboards

### Option 1: Manual Testing
Visit the frontend and backend URLs multiple times to generate traffic.

### Option 2: Automated Traffic Generation
```powershell
# Run traffic generation script (Windows)
.\scripts\generate-traffic.ps1
```

This script will:
- Generate continuous requests to frontend and backend
- Show request status in console
- Help populate Grafana dashboards with data

## 🔍 Troubleshooting

### Common Issues

#### 1. Pods in Pending State
```bash
# Check pod details
kubectl describe pod <pod-name> -n <namespace>

# Check PVC status
kubectl get pvc --all-namespaces
```

#### 2. Image Pull Errors
```bash
# Pre-pull required images
docker pull node:18-alpine
docker pull nginx:alpine
docker pull postgres:15-alpine
docker pull redis:7-alpine
```

#### 3. Port Forward Issues
```bash
# Check if ports are already in use
netstat -an | findstr :8080
netstat -an | findstr :8081
netstat -an | findstr :30080
netstat -an | findstr :30300
netstat -an | findstr :30686
netstat -an | findstr :30900
netstat -an | findstr :3100
```

#### 4. Service Not Accessible
```bash
# Check service status
kubectl get svc --all-namespaces

# Check pod logs
kubectl logs <pod-name> -n <namespace>
```

### Reset Everything
```bash
# Clean up all resources
kubectl delete namespace argocd
kubectl delete namespace observability
kubectl delete namespace microservices
kubectl delete namespace istio-system
kubectl delete namespace security
kubectl delete namespace platform

# Or use cleanup script
.\scripts\cleanup.ps1
```

## 📊 Monitoring and Observability

### Grafana Dashboards
1. **Kubernetes Cluster Dashboard**
   - Shows cluster resource usage
   - Node status and metrics
   - Pod resource consumption

2. **Istio Service Dashboard**
   - Service mesh metrics
   - Request rates and latencies
   - Error rates and success rates

3. **Istio Workload Dashboard**
   - Workload-specific metrics
   - Sidecar proxy metrics
   - Traffic patterns

### Key Metrics to Monitor
- **Request Rate**: `istio_requests_total`
- **Response Time**: `istio_request_duration_milliseconds`
- **Error Rate**: `istio_requests_total{response_code!="200"}`
- **CPU Usage**: `rate(container_cpu_usage_seconds_total[5m])`
- **Memory Usage**: `container_memory_usage_bytes`

## 🔒 Security Features

### Falco (Runtime Security)
- Monitors container runtime
- Detects security threats
- Generates alerts for suspicious activities

### OPA Gatekeeper (Policy Enforcement)
- Enforces security policies
- Validates resource configurations
- Prevents non-compliant deployments

### Network Policies
- Controls traffic flow between pods
- Implements micro-segmentation
- Enhances security posture

## 🎯 Success Criteria

### ✅ Platform is Working When:
1. **Frontend** loads at http://localhost:8081
2. **Backend API** responds at http://localhost:8080/health
3. **Argo CD** shows applications as "Synced" and "Healthy"
4. **Grafana** displays populated dashboards
5. **Jaeger** shows traces from services
6. **Prometheus** shows metrics and targets
7. **All port forwards** are active and working

### 📈 Performance Indicators
- All pods are in "Running" state
- Services respond within 2-3 seconds
- Grafana dashboards show data after traffic generation
- No critical errors in pod logs

## 🚀 Next Steps

### Production Considerations
1. **Persistent Storage**: Configure proper storage classes
2. **Ingress Controller**: Set up proper ingress for external access
3. **SSL/TLS**: Configure certificates for HTTPS
4. **Backup Strategy**: Implement backup for persistent data
5. **Monitoring**: Set up alerting rules
6. **Security**: Implement RBAC and network policies

### Scaling
1. **Horizontal Pod Autoscaling**: Configure HPA for microservices
2. **Vertical Pod Autoscaling**: Configure VPA for resource optimization
3. **Cluster Autoscaling**: Scale cluster nodes based on demand

## 📞 Support

### Getting Help
1. Check the troubleshooting section above
2. Review pod logs for errors
3. Verify all prerequisites are met
4. Ensure all port forwards are active

### Useful Commands
```bash
# Get all resources
kubectl get all --all-namespaces

# Check cluster info
kubectl cluster-info

# Get node information
kubectl get nodes -o wide

# Check events
kubectl get events --sort-by=.metadata.creationTimestamp
```

---

## 🎉 Congratulations!

You now have a fully functional Kubernetes platform with:
- ✅ GitOps with Argo CD
- ✅ Service Mesh with Istio
- ✅ Complete Observability Stack
- ✅ Microservices Architecture
- ✅ Security Tools Integration
- ✅ Traffic Generation for Testing

**Happy Kubernetes-ing!** 🚀