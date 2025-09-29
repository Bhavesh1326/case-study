# Troubleshooting Guide

This guide helps you diagnose and resolve common issues with the Local Kubernetes Platform.

## Quick Diagnostics

### Check Overall Status
```bash
# Check all pods across namespaces
kubectl get pods --all-namespaces

# Check services
kubectl get svc --all-namespaces

# Check ingress
kubectl get ingress --all-namespaces

# Check persistent volumes
kubectl get pv,pvc --all-namespaces
```

### Check Resource Usage
```bash
# Check node resources
kubectl top nodes

# Check pod resources
kubectl top pods --all-namespaces

# Check cluster info
kubectl cluster-info
```

## Common Issues and Solutions

### 1. Pod Issues

#### Pods Stuck in Pending State
**Symptoms**: Pods remain in `Pending` state
```bash
kubectl get pods -n microservices
# NAME      READY   STATUS    RESTARTS   AGE
# frontend  0/1     Pending   0          5m
```

**Diagnosis**:
```bash
kubectl describe pod frontend-xxx -n microservices
```

**Common Causes & Solutions**:

1. **Insufficient Resources**
   ```bash
   # Check node resources
   kubectl describe nodes
   
   # Solution: Increase node resources or adjust pod requests
   ```

2. **No Available Nodes**
   ```bash
   # Check node status
   kubectl get nodes
   
   # Solution: Ensure cluster has running nodes
   ```

3. **Storage Issues**
   ```bash
   # Check storage classes
   kubectl get storageclass
   
   # Check PVC status
   kubectl get pvc -n microservices
   
   # Solution: Ensure storage class exists and PVCs are bound
   ```

#### Pods Stuck in ContainerCreating State
**Symptoms**: Pods stuck in `ContainerCreating` state
```bash
kubectl get pods -n microservices
# NAME      READY   STATUS              RESTARTS   AGE
# frontend  0/1     ContainerCreating   0          10m
```

**Diagnosis**:
```bash
kubectl describe pod frontend-xxx -n microservices
kubectl get events -n microservices --sort-by='.lastTimestamp'
```

**Common Causes & Solutions**:

1. **Image Pull Issues**
   ```bash
   # Check image pull secrets
   kubectl get secrets -n microservices
   
   # Solution: Add image pull secret or use public images
   ```

2. **Volume Mount Issues**
   ```bash
   # Check volume mounts
   kubectl describe pod frontend-xxx -n microservices | grep -A 10 "Volumes:"
   
   # Solution: Ensure volumes exist and are accessible
   ```

#### Pods Crashing (CrashLoopBackOff)
**Symptoms**: Pods restarting repeatedly
```bash
kubectl get pods -n microservices
# NAME      READY   STATUS             RESTARTS   AGE
# backend   0/1     CrashLoopBackOff   5          10m
```

**Diagnosis**:
```bash
# Check pod logs
kubectl logs backend-xxx -n microservices

# Check previous container logs
kubectl logs backend-xxx -n microservices --previous

# Check pod description
kubectl describe pod backend-xxx -n microservices
```

**Common Causes & Solutions**:

1. **Application Errors**
   ```bash
   # Check application logs
   kubectl logs backend-xxx -n microservices
   
   # Solution: Fix application code or configuration
   ```

2. **Resource Limits**
   ```bash
   # Check resource usage
   kubectl top pod backend-xxx -n microservices
   
   # Solution: Increase resource limits or optimize application
   ```

3. **Configuration Issues**
   ```bash
   # Check environment variables
   kubectl describe pod backend-xxx -n microservices | grep -A 10 "Environment:"
   
   # Solution: Fix configuration or environment variables
   ```

### 2. Service Issues

#### Services Not Accessible
**Symptoms**: Cannot access services via NodePort or ClusterIP
```bash
kubectl get svc -n microservices
# NAME      TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
# frontend  ClusterIP   10.96.123.45   <none>        80/TCP    10m
```

**Diagnosis**:
```bash
# Check service endpoints
kubectl get endpoints -n microservices

# Check service details
kubectl describe svc frontend -n microservices

# Test service connectivity
kubectl run test-pod --image=busybox --rm -it -- nslookup frontend.microservices.svc.cluster.local
```

**Common Causes & Solutions**:

1. **No Endpoints**
   ```bash
   # Check if pods are running and have correct labels
   kubectl get pods -n microservices --show-labels
   
   # Solution: Ensure pod labels match service selector
   ```

2. **Port Mismatch**
   ```bash
   # Check service and pod ports
   kubectl get svc frontend -n microservices -o yaml | grep -A 5 "ports:"
   kubectl get pod frontend-xxx -n microservices -o yaml | grep -A 5 "ports:"
   
   # Solution: Ensure ports match between service and pod
   ```

3. **Network Policies**
   ```bash
   # Check network policies
   kubectl get networkpolicies -n microservices
   
   # Solution: Adjust network policies or create allow rules
   ```

### 3. Istio Issues

#### Sidecar Not Injected
**Symptoms**: Pods don't have Istio sidecar
```bash
kubectl get pods -n microservices -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[*].name}{"\n"}{end}'
# frontend-xxx    frontend
# backend-xxx     backend
```

**Diagnosis**:
```bash
# Check namespace labels
kubectl get namespace microservices --show-labels

# Check Istio installation
istioctl verify-install
```

**Solutions**:

1. **Enable Sidecar Injection**
   ```bash
   # Label namespace for sidecar injection
   kubectl label namespace microservices istio-injection=enabled --overwrite
   
   # Restart pods to inject sidecar
   kubectl rollout restart deployment/frontend -n microservices
   kubectl rollout restart deployment/backend -n microservices
   ```

2. **Manual Sidecar Injection**
   ```bash
   # Inject sidecar manually
   istioctl kube-inject -f microservices/manifests/frontend-deployment.yaml | kubectl apply -f -
   ```

#### Istio Gateway Not Working
**Symptoms**: Cannot access services through Istio gateway
```bash
kubectl get gateway -n istio-system
kubectl get virtualservice -n istio-system
```

**Diagnosis**:
```bash
# Check gateway status
kubectl describe gateway main-gateway -n istio-system

# Check virtual service
kubectl describe virtualservice main-virtual-service -n istio-system

# Check ingress gateway pods
kubectl get pods -n istio-system -l app=istio-ingressgateway
```

**Solutions**:

1. **Check Gateway Configuration**
   ```bash
   # Verify gateway configuration
   kubectl get gateway main-gateway -n istio-system -o yaml
   
   # Solution: Fix gateway configuration
   ```

2. **Check Virtual Service**
   ```bash
   # Verify virtual service configuration
   kubectl get virtualservice main-virtual-service -n istio-system -o yaml
   
   # Solution: Fix virtual service configuration
   ```

### 4. Argo CD Issues

#### Applications Not Syncing
**Symptoms**: Argo CD applications stuck in `OutOfSync` or `Unknown` state
```bash
kubectl get applications -n argocd
# NAME             SYNC STATUS   HEALTH STATUS
# platform-app     OutOfSync     Unknown
```

**Diagnosis**:
```bash
# Check application status
kubectl describe application platform-app -n argocd

# Check Argo CD logs
kubectl logs -n argocd deployment/argocd-application-controller
kubectl logs -n argocd deployment/argocd-server
```

**Common Causes & Solutions**:

1. **Repository Access Issues**
   ```bash
   # Check repository connectivity
   kubectl get application platform-app -n argocd -o yaml | grep -A 5 "source:"
   
   # Solution: Check repository URL and credentials
   ```

2. **Sync Policy Issues**
   ```bash
   # Check sync policy
   kubectl get application platform-app -n argocd -o yaml | grep -A 10 "syncPolicy:"
   
   # Solution: Adjust sync policy or trigger manual sync
   ```

3. **Resource Conflicts**
   ```bash
   # Check for resource conflicts
   kubectl get events --all-namespaces --sort-by='.lastTimestamp'
   
   # Solution: Resolve resource conflicts
   ```

### 5. Observability Issues

#### Prometheus Not Collecting Metrics
**Symptoms**: No metrics in Prometheus or Grafana
```bash
kubectl get pods -n observability -l app.kubernetes.io/name=prometheus
```

**Diagnosis**:
```bash
# Check Prometheus logs
kubectl logs -n observability deployment/prometheus-server

# Check service discovery
kubectl get endpoints -n observability

# Check Prometheus configuration
kubectl get configmap -n observability prometheus-server -o yaml
```

**Solutions**:

1. **Service Discovery Issues**
   ```bash
   # Check if services are properly labeled
   kubectl get svc --all-namespaces --show-labels | grep prometheus.io/scrape
   
   # Solution: Add proper labels to services
   ```

2. **RBAC Issues**
   ```bash
   # Check Prometheus service account
   kubectl get serviceaccount -n observability prometheus-server
   
   # Solution: Ensure proper RBAC permissions
   ```

#### Grafana Not Accessible
**Symptoms**: Cannot access Grafana dashboard
```bash
kubectl get svc -n observability prometheus-grafana
```

**Diagnosis**:
```bash
# Check Grafana pod status
kubectl get pods -n observability -l app.kubernetes.io/name=grafana

# Check service configuration
kubectl describe svc prometheus-grafana -n observability

# Check Grafana logs
kubectl logs -n observability deployment/prometheus-grafana
```

**Solutions**:

1. **Service Configuration**
   ```bash
   # Check NodePort configuration
   kubectl get svc prometheus-grafana -n observability -o yaml | grep nodePort
   
   # Solution: Verify NodePort configuration
   ```

2. **Authentication Issues**
   ```bash
   # Check Grafana secret
   kubectl get secret -n observability prometheus-grafana
   
   # Solution: Reset Grafana admin password
   ```

### 6. Security Issues

#### Falco Not Detecting Events
**Symptoms**: No security events in Falco logs
```bash
kubectl get pods -n security -l app=falco
```

**Diagnosis**:
```bash
# Check Falco logs
kubectl logs -n security deployment/falco

# Check Falco configuration
kubectl get configmap -n security falco -o yaml
```

**Solutions**:

1. **Configuration Issues**
   ```bash
   # Check Falco rules
   kubectl exec -n security deployment/falco -- falco --list-rules
   
   # Solution: Fix Falco configuration
   ```

2. **RBAC Issues**
   ```bash
   # Check Falco service account
   kubectl get serviceaccount -n security falco
   
   # Solution: Ensure proper RBAC permissions
   ```

#### OPA Gatekeeper Not Enforcing Policies
**Symptoms**: Policies not being enforced
```bash
kubectl get constrainttemplates -n security
kubectl get k8srequiredlabels -n security
```

**Diagnosis**:
```bash
# Check Gatekeeper logs
kubectl logs -n security deployment/gatekeeper-controller-manager

# Check constraint status
kubectl describe k8srequiredlabels must-have-labels -n security
```

**Solutions**:

1. **Policy Configuration**
   ```bash
   # Check constraint template
   kubectl get constrainttemplate k8srequiredlabels -n security -o yaml
   
   # Solution: Fix policy configuration
   ```

2. **Admission Controller Issues**
   ```bash
   # Check admission controller
   kubectl get validatingwebhookconfigurations
   
   # Solution: Ensure admission controller is properly configured
   ```

## Debugging Commands

### General Debugging
```bash
# Get detailed pod information
kubectl describe pod <pod-name> -n <namespace>

# Get pod logs
kubectl logs <pod-name> -n <namespace>

# Get previous container logs
kubectl logs <pod-name> -n <namespace> --previous

# Execute commands in pod
kubectl exec -it <pod-name> -n <namespace> -- /bin/sh

# Port forward to service
kubectl port-forward svc/<service-name> -n <namespace> <local-port>:<service-port>
```

### Istio Debugging
```bash
# Check Istio installation
istioctl verify-install

# Get Istio configuration
istioctl proxy-config cluster <pod-name> -n <namespace>

# Get Istio routes
istioctl proxy-config routes <pod-name> -n <namespace>

# Check sidecar injection
istioctl proxy-status
```

### Argo CD Debugging
```bash
# Get Argo CD application status
argocd app get <app-name>

# Sync application
argocd app sync <app-name>

# Get application logs
argocd app logs <app-name>
```

## Performance Issues

### High Resource Usage
```bash
# Check resource usage
kubectl top nodes
kubectl top pods --all-namespaces

# Check resource limits
kubectl describe nodes | grep -A 5 "Allocated resources"

# Check pod resource usage
kubectl describe pod <pod-name> -n <namespace> | grep -A 10 "Requests:"
```

### Slow Response Times
```bash
# Check Istio metrics
kubectl exec -it <pod-name> -n <namespace> -- curl localhost:15000/stats/prometheus

# Check service mesh configuration
istioctl proxy-config cluster <pod-name> -n <namespace>

# Check network policies
kubectl get networkpolicies --all-namespaces
```

## Getting Help

### Logs Collection
```bash
# Collect all logs
kubectl logs --all-containers=true --all-namespaces=true > all-logs.txt

# Collect specific namespace logs
kubectl logs --all-containers=true -n microservices > microservices-logs.txt

# Collect events
kubectl get events --all-namespaces --sort-by='.lastTimestamp' > events.txt
```

### System Information
```bash
# Get cluster information
kubectl cluster-info dump > cluster-info.txt

# Get node information
kubectl describe nodes > nodes.txt

# Get all resources
kubectl get all --all-namespaces > all-resources.txt
```

### Community Resources
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Istio Documentation](https://istio.io/latest/docs/)
- [Argo CD Documentation](https://argo-cd.readthedocs.io/)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Falco Documentation](https://falco.org/docs/)
