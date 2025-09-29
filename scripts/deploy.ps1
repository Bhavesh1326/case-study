# Local Kubernetes Platform Deployment Script for Windows
# This script deploys the complete platform with GitOps, Istio, and Observability

param(
    [switch]$SkipClusterSetup,
    [switch]$SkipIstio,
    [switch]$SkipArgoCD,
    [switch]$SkipObservability,
    [switch]$SkipSecurity,
    [switch]$SkipMicroservices
)

# Function to print colored output
function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Check prerequisites
function Test-Prerequisites {
    Write-Status "Checking prerequisites..."
    
    # Check if kubectl is installed
    if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
        Write-Error "kubectl is not installed. Please install kubectl first."
        exit 1
    }
    
    # Check if helm is installed
    if (-not (Get-Command helm -ErrorAction SilentlyContinue)) {
        Write-Error "helm is not installed. Please install Helm 3.x first."
        exit 1
    }
    
    # Check if Docker is running
    try {
        docker info | Out-Null
    }
    catch {
        Write-Error "Docker is not running. Please start Docker first."
        exit 1
    }
    
    # Check if Kubernetes cluster is accessible
    try {
        kubectl cluster-info | Out-Null
    }
    catch {
        Write-Error "Kubernetes cluster is not accessible. Please ensure your cluster is running."
        exit 1
    }
    
    Write-Success "All prerequisites met!"
}

# Create namespaces
function New-Namespaces {
    Write-Status "Creating namespaces..."
    
    $namespaces = @("argocd", "istio-system", "observability", "microservices", "security")
    
    foreach ($ns in $namespaces) {
        kubectl create namespace $ns --dry-run=client -o yaml | kubectl apply -f -
    }
    
    Write-Success "Namespaces created!"
}

# Install Istio
function Install-Istio {
    if ($SkipIstio) {
        Write-Status "Skipping Istio installation..."
        return
    }
    
    Write-Status "Installing Istio service mesh..."
    
    # Check if istioctl is available
    if (-not (Get-Command istioctl -ErrorAction SilentlyContinue)) {
        Write-Status "Downloading Istio..."
        $istioVersion = "1.20.0"
        $downloadUrl = "https://github.com/istio/istio/releases/download/$istioVersion/istio-$istioVersion-win.zip"
        $zipFile = "istio-$istioVersion-win.zip"
        
        Invoke-WebRequest -Uri $downloadUrl -OutFile $zipFile
        Expand-Archive -Path $zipFile -DestinationPath "." -Force
        $env:PATH += ";$PWD\istio-$istioVersion\bin"
        Remove-Item $zipFile
    }
    
    # Install Istio
    istioctl install --set values.defaultRevision=default -y
    
    # Enable sidecar injection for namespaces
    kubectl label namespace microservices istio-injection=enabled --overwrite
    kubectl label namespace observability istio-injection=enabled --overwrite
    
    Write-Success "Istio installed successfully!"
}

# Install Argo CD
function Install-ArgoCD {
    if ($SkipArgoCD) {
        Write-Status "Skipping Argo CD installation..."
        return
    }
    
    Write-Status "Installing Argo CD..."
    
    # Add Argo CD Helm repository
    helm repo add argo https://argoproj.github.io/argo-helm
    helm repo update
    
    # Install Argo CD
    helm upgrade --install argocd argo/argo-cd `
        --namespace argocd `
        --set server.service.type=NodePort `
        --set server.service.nodePortHttp=30080 `
        --set server.extraArgs[0]="--insecure" `
        --wait
    
    # Wait for Argo CD to be ready
    kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
    
    Write-Success "Argo CD installed successfully!"
}

# Install Observability Stack
function Install-Observability {
    if ($SkipObservability) {
        Write-Status "Skipping observability stack installation..."
        return
    }
    
    Write-Status "Installing observability stack..."
    
    # Add Helm repositories
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo add grafana https://grafana.github.io/helm-charts
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
    
    Write-Success "Observability stack installed successfully!"
}

# Install Security Tools
function Install-Security {
    if ($SkipSecurity) {
        Write-Status "Skipping security tools installation..."
        return
    }
    
    Write-Status "Installing security tools..."
    
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
    
    Write-Success "Security tools installed successfully!"
}

# Deploy Sample Microservices
function Deploy-Microservices {
    if ($SkipMicroservices) {
        Write-Status "Skipping microservices deployment..."
        return
    }
    
    Write-Status "Deploying sample microservices..."
    
    # Apply microservices manifests
    kubectl apply -f microservices/manifests/ -R
    kubectl apply -f manifests/ -R
    
    Write-Success "Microservices deployed successfully!"
}

# Setup Argo CD Applications
function Setup-ArgoCDApps {
    Write-Status "Setting up Argo CD applications..."
    
    # Apply Argo CD application manifests
    kubectl apply -f argocd/applications/ -R
    
    Write-Success "Argo CD applications configured!"
}

# Display access information
function Show-AccessInfo {
    Write-Success "Deployment completed successfully!"
    Write-Host ""
    Write-Host "Access Information:" -ForegroundColor Cyan
    Write-Host "==================" -ForegroundColor Cyan
    Write-Host "Argo CD UI:     http://localhost:30080"
    Write-Host "Grafana:        http://localhost:30000"
    Write-Host "Jaeger:         http://localhost:30686"
    Write-Host "Prometheus:     http://localhost:30090"
    Write-Host ""
    Write-Host "Argo CD Admin Password:" -ForegroundColor Cyan
    Write-Host "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath=`"{.data.password}`" | base64 -d"
    Write-Host ""
    Write-Host "Sample Application:" -ForegroundColor Cyan
    Write-Host "kubectl port-forward -n microservices svc/frontend 8081:80"
    Write-Host "Then access: http://localhost:8081"
}

# Main deployment function
function Main {
    Write-Status "Starting Local Kubernetes Platform deployment..."
    
    Test-Prerequisites
    New-Namespaces
    Install-Istio
    Install-ArgoCD
    Install-Observability
    Install-Security
    Deploy-Microservices
    Setup-ArgoCDApps
    Show-AccessInfo
    
    Write-Success "Platform deployment completed!"
}

# Run main function
Main