# 🚀 Kubernetes Platform Deployment Checklist

## ✅ Pre-Deployment Checklist

- [ ] Docker Desktop is running
- [ ] Kubernetes cluster is set up (minikube/kind/Docker Desktop)
- [ ] kubectl is installed and working
- [ ] Helm is installed
- [ ] Git is installed

## 🚀 Deployment Steps

### Step 1: Clone Repository
```bash
git clone https://github.com/Bhavesh1326/case-study.git
cd case-study
```

### Step 2: Deploy Platform
```powershell
# Windows
.\scripts\deploy.ps1
```

### Step 3: Wait for Deployment (5-10 minutes)
```bash
# Check all pods are running
kubectl get pods --all-namespaces
```

### Step 4: Setup Port Forwards (7 terminals needed)

#### Terminal 1: Frontend
```bash
kubectl port-forward -n microservices svc/frontend 8081:80
```

#### Terminal 2: Backend
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

## 🧪 Testing Checklist

### Test All Services
- [ ] **Frontend**: http://localhost:8081 (should show demo page)
- [ ] **Backend**: http://localhost:8080/health (should return JSON)
- [ ] **Argo CD**: http://localhost:30080 (login: admin / [get password])
- [ ] **Grafana**: http://localhost:30300 (login: admin / admin123)
- [ ] **Jaeger**: http://localhost:30686 (should show UI)
- [ ] **Prometheus**: http://localhost:30900 (should show UI)
- [ ] **Loki**: http://localhost:3100 (may show 404, but service is running)

### Get Argo CD Password
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
```

## 🚦 Generate Traffic
```powershell
# Run traffic generation script
.\scripts\generate-traffic.ps1
```

## ✅ Success Criteria
- [ ] All 7 port forwards are active
- [ ] Frontend loads and shows "Healthy" status
- [ ] Backend API returns health data
- [ ] Argo CD shows applications as "Synced" and "Healthy"
- [ ] Grafana dashboards are populated with data
- [ ] Jaeger shows traces from services
- [ ] Prometheus shows metrics and targets

## 🆘 If Something Fails

### Check Pod Status
```bash
kubectl get pods --all-namespaces
kubectl describe pod <pod-name> -n <namespace>
```

### Check Logs
```bash
kubectl logs <pod-name> -n <namespace>
```

### Restart Services
```bash
kubectl rollout restart deployment <deployment-name> -n <namespace>
```

### Clean Up and Restart
```bash
kubectl delete namespace argocd
kubectl delete namespace observability
kubectl delete namespace microservices
kubectl delete namespace istio-system
kubectl delete namespace security
kubectl delete namespace platform
```

## 📚 Documentation
- **Complete Guide**: `docs/COMPLETE_DEPLOYMENT_GUIDE.md`
- **Quick Reference**: `docs/QUICK_REFERENCE.md`
- **Troubleshooting**: `docs/troubleshooting.md`

---

**🎉 You're all set! Your Kubernetes platform is ready for testing!**
