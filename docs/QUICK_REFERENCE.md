# Quick Reference Card

## 🚀 Quick Start Commands

### 1. Clone and Setup
```bash
git clone https://github.com/Bhavesh1326/case-study.git
cd case-study
```

### 2. Deploy Platform
```powershell
# Windows
.\scripts\deploy.ps1

# Linux/macOS
./scripts/deploy.sh
```

### 3. Port Forwards (Run in separate terminals)
```bash
# Terminal 1: Frontend
kubectl port-forward -n microservices svc/frontend 8081:80

# Terminal 2: Backend
kubectl port-forward -n microservices svc/backend 8080:8080

# Terminal 3: Argo CD
kubectl port-forward -n argocd svc/argocd-server 30080:80

# Terminal 4: Grafana
kubectl port-forward -n observability svc/prometheus-grafana 30300:80

# Terminal 5: Jaeger
kubectl port-forward -n observability svc/jaeger-query 30686:16686

# Terminal 6: Prometheus
kubectl port-forward -n observability svc/prometheus-kube-prometheus-prometheus 30900:9090

# Terminal 7: Loki
kubectl port-forward -n observability svc/loki 3100:3100
```

## 🔐 Access URLs & Credentials

| Service | URL | Username | Password |
|---------|-----|----------|----------|
| **Frontend** | http://localhost:8081 | - | - |
| **Backend API** | http://localhost:8080/health | - | - |
| **Argo CD** | http://localhost:30080 | admin | `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' \| base64 -d` |
| **Grafana** | http://localhost:30300 | admin | admin123 |
| **Jaeger** | http://localhost:30686 | - | - |
| **Prometheus** | http://localhost:30900 | - | - |
| **Loki** | http://localhost:3100 | - | - |

## 🧪 Test Commands

### Test Frontend
```bash
curl http://localhost:8081
```

### Test Backend
```bash
curl http://localhost:8080/health
curl http://localhost:8080/api/users
curl http://localhost:8080/api/status
```

### Test Argo CD
```bash
# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
```

## 🔍 Troubleshooting Commands

### Check Pod Status
```bash
kubectl get pods --all-namespaces
kubectl get pods -n microservices
kubectl get pods -n observability
kubectl get pods -n argocd
```

### Check Services
```bash
kubectl get svc --all-namespaces
```

### Check Logs
```bash
kubectl logs <pod-name> -n <namespace>
kubectl logs -f <pod-name> -n <namespace>  # Follow logs
```

### Check Events
```bash
kubectl get events --sort-by=.metadata.creationTimestamp
```

### Check PVC Status
```bash
kubectl get pvc --all-namespaces
```

## 🚦 Traffic Generation

### Manual Testing
Visit these URLs multiple times:
- http://localhost:8081
- http://localhost:8080/health
- http://localhost:8080/api/users

### Automated Traffic
```powershell
# Windows
.\scripts\generate-traffic.ps1
```

## 🧹 Cleanup Commands

### Clean Everything
```bash
kubectl delete namespace argocd
kubectl delete namespace observability
kubectl delete namespace microservices
kubectl delete namespace istio-system
kubectl delete namespace security
kubectl delete namespace platform
```

### Or use cleanup script
```powershell
.\scripts\cleanup.ps1
```

## 📊 Key Metrics Queries (Prometheus)

```bash
# Check if targets are up
up

# Istio request metrics
istio_requests_total

# CPU usage
rate(container_cpu_usage_seconds_total[5m])

# Memory usage
container_memory_usage_bytes

# Pod info
kubernetes_pod_info
```

## 🔧 Common Fixes

### Fix Image Pull Issues
```bash
docker pull node:18-alpine
docker pull nginx:alpine
docker pull postgres:15-alpine
docker pull redis:7-alpine
```

### Restart Grafana
```bash
kubectl rollout restart deployment prometheus-grafana -n observability
```

### Check Port Usage
```bash
# Windows
netstat -an | findstr :8080
netstat -an | findstr :8081
netstat -an | findstr :30080
netstat -an | findstr :30300
netstat -an | findstr :30686
netstat -an | findstr :30900
netstat -an | findstr :3100

# Linux/macOS
lsof -i :8080
lsof -i :8081
lsof -i :30080
lsof -i :30300
lsof -i :30686
lsof -i :30900
lsof -i :3100
```

## ✅ Success Checklist

- [ ] All pods are running
- [ ] Frontend loads at http://localhost:8081
- [ ] Backend responds at http://localhost:8080/health
- [ ] Argo CD accessible at http://localhost:30080
- [ ] Grafana accessible at http://localhost:30300
- [ ] Jaeger accessible at http://localhost:30686
- [ ] Prometheus accessible at http://localhost:30900
- [ ] Loki accessible at http://localhost:3100
- [ ] Grafana dashboards show data after traffic generation
- [ ] All port forwards are active

## 🆘 Emergency Commands

### If everything breaks
```bash
# Stop all port forwards (Ctrl+C in each terminal)
# Then restart them one by one

# Check cluster status
kubectl get nodes
kubectl cluster-info

# Restart problematic deployments
kubectl rollout restart deployment <deployment-name> -n <namespace>
```

### Reset Argo CD password
```bash
kubectl -n argocd delete secret argocd-initial-admin-secret
kubectl -n argocd patch secret argocd-secret -p '{"stringData":{"admin.password":"$2a$10$rRyBsGSHK6.uc8fntPwVFOBLQdUx8Q8Q8Q8Q8Q8Q8Q8Q8Q8Q8Q8Q8Q8"}}'
```

---

**Remember**: Keep all port-forward terminals open while testing!
