# Deployment Guide

This guide provides step-by-step instructions for deploying the Local Kubernetes Platform.

## Prerequisites

### Required Software

1. **Docker Desktop**
   - Download from: https://www.docker.com/products/docker-desktop
   - Enable Kubernetes in Docker Desktop settings

2. **kubectl**
   - Download from: https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/
   - Or install via Chocolatey: `choco install kubernetes-cli`

3. **Helm 3.x**
   - Download from: https://helm.sh/docs/intro/install/
   - Or install via Chocolatey: `choco install kubernetes-helm`

4. **Git**
   - Download from: https://git-scm.com/download/win
   - Or install via Chocolatey: `choco install git`

### Optional Software

1. **kind** (Kubernetes in Docker)
   - Download from: https://kind.sigs.k8s.io/docs/user/quick-start/
   - Alternative to Docker Desktop Kubernetes

2. **minikube**
   - Download from: https://minikube.sigs.k8s.io/docs/start/
   - Alternative to Docker Desktop Kubernetes

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/Bhavesh1326/case-study.git
cd case-study
```

### 2. Deploy the Platform

#### Windows (PowerShell)
```powershell
.\scripts\deploy.ps1
```

#### Linux/macOS (Bash)
```bash
./scripts/deploy.sh
```

### 3. Access the Services

After deployment, you can access the following services:

- **Argo CD UI**: http://localhost:30080
- **Grafana**: http://localhost:30000
- **Jaeger**: http://localhost:30686
- **Prometheus**: http://localhost:30090

### 4. Get Argo CD Admin Password

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
```

### 5. Access Sample Application

```bash
kubectl port-forward -n microservices svc/frontend 8081:80
```

Then open: http://localhost:8081

## Manual Deployment Steps

If you prefer to deploy components individually:

### 1. Create Namespaces

```bash
kubectl apply -f manifests/namespace.yaml
```

### 2. Install Istio

```bash
# Download Istio
curl -L https://istio.io/downloadIstio | sh -
export PATH=$PWD/istio-*/bin:$PATH

# Install Istio
istioctl install --set values.defaultRevision=default -y

# Enable sidecar injection
kubectl label namespace microservices istio-injection=enabled --overwrite
kubectl label namespace observability istio-injection=enabled --overwrite
```

### 3. Install Argo CD

```bash
# Add Helm repository
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# Install Argo CD
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd \
  --set server.service.type=NodePort \
  --set server.service.nodePortHttp=30080 \
  --set server.extraArgs[0]="--insecure" \
  --wait
```

### 4. Install Observability Stack

```bash
# Add Helm repositories
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add jaegertracing https://jaegertracing.github.io/helm-charts
helm repo update

# Install Prometheus Stack
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
  --namespace observability \
  --values observability/manifests/prometheus-values.yaml \
  --wait

# Install Jaeger
helm upgrade --install jaeger jaegertracing/jaeger \
  --namespace observability \
  --values observability/manifests/jaeger-values.yaml \
  --wait
```

### 5. Install Security Tools

```bash
# Add Helm repositories
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo add gatekeeper https://open-policy-agent.github.io/gatekeeper/charts
helm repo update

# Install Falco
helm upgrade --install falco falcosecurity/falco \
  --namespace security \
  --values security/manifests/falco-values.yaml \
  --wait

# Install OPA Gatekeeper
helm upgrade --install gatekeeper gatekeeper/gatekeeper \
  --namespace security \
  --wait

# Apply Gatekeeper policies
kubectl apply -f security/manifests/opa-gatekeeper-policies.yaml
```

### 6. Deploy Microservices

```bash
# Deploy microservices
kubectl apply -f microservices/manifests/ -R

# Apply network policies
kubectl apply -f manifests/network-policies.yaml
```

### 7. Setup Argo CD Applications

```bash
# Apply Argo CD applications
kubectl apply -f argocd/applications/ -R
```

## Verification

### Check Pod Status

```bash
# Check all pods
kubectl get pods --all-namespaces

# Check specific namespaces
kubectl get pods -n argocd
kubectl get pods -n istio-system
kubectl get pods -n observability
kubectl get pods -n microservices
kubectl get pods -n security
```

### Check Services

```bash
# Check services
kubectl get svc --all-namespaces

# Check NodePort services
kubectl get svc --all-namespaces | grep NodePort
```

### Check Istio Configuration

```bash
# Check Istio installation
istioctl verify-install

# Check sidecar injection
kubectl get pods -n microservices -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[*].name}{"\n"}{end}'
```

## Troubleshooting

### Common Issues

1. **Pods stuck in Pending state**
   - Check resource availability: `kubectl describe nodes`
   - Check storage classes: `kubectl get storageclass`

2. **Services not accessible**
   - Check service endpoints: `kubectl get endpoints`
   - Check NodePort assignments: `kubectl get svc`

3. **Istio sidecar not injected**
   - Check namespace labels: `kubectl get namespace microservices --show-labels`
   - Manually inject: `istioctl kube-inject -f deployment.yaml | kubectl apply -f -`

4. **Argo CD sync issues**
   - Check application status: `kubectl get applications -n argocd`
   - Check sync logs: `kubectl logs -n argocd deployment/argocd-application-controller`

### Logs

```bash
# Check pod logs
kubectl logs -n microservices deployment/frontend
kubectl logs -n microservices deployment/backend

# Check Argo CD logs
kubectl logs -n argocd deployment/argocd-server
kubectl logs -n argocd deployment/argocd-application-controller

# Check Istio logs
kubectl logs -n istio-system deployment/istiod
kubectl logs -n istio-system deployment/istio-ingressgateway
```

## Cleanup

To remove all components:

```bash
# Delete applications
kubectl delete applications --all -n argocd

# Delete microservices
kubectl delete -f microservices/manifests/ -R

# Delete observability stack
helm uninstall prometheus -n observability
helm uninstall jaeger -n observability

# Delete security tools
helm uninstall falco -n security
helm uninstall gatekeeper -n security

# Delete Argo CD
helm uninstall argocd -n argocd

# Delete Istio
istioctl uninstall --purge -y

# Delete namespaces
kubectl delete namespace argocd istio-system observability microservices security
```

## Next Steps

1. **Configure GitOps**: Set up your Git repository and configure Argo CD applications
2. **Customize Dashboards**: Import additional Grafana dashboards
3. **Add Security Policies**: Create custom OPA Gatekeeper policies
4. **Scale Applications**: Deploy additional microservices
5. **Monitor Performance**: Set up alerts and monitoring rules
