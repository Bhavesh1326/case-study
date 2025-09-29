#!/bin/bash

# Local Kubernetes Platform Deployment Script
# This script deploys the complete platform with GitOps, Istio, and Observability

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if kubectl is installed
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed. Please install kubectl first."
        exit 1
    fi
    
    # Check if helm is installed
    if ! command -v helm &> /dev/null; then
        print_error "helm is not installed. Please install Helm 3.x first."
        exit 1
    fi
    
    # Check if Docker is running
    if ! docker info &> /dev/null; then
        print_error "Docker is not running. Please start Docker first."
        exit 1
    fi
    
    # Check if Kubernetes cluster is accessible
    if ! kubectl cluster-info &> /dev/null; then
        print_error "Kubernetes cluster is not accessible. Please ensure your cluster is running."
        exit 1
    fi
    
    print_success "All prerequisites met!"
}

# Create namespace
create_namespace() {
    print_status "Creating namespaces..."
    kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
    kubectl create namespace istio-system --dry-run=client -o yaml | kubectl apply -f -
    kubectl create namespace observability --dry-run=client -o yaml | kubectl apply -f -
    kubectl create namespace microservices --dry-run=client -o yaml | kubectl apply -f -
    kubectl create namespace security --dry-run=client -o yaml | kubectl apply -f -
    print_success "Namespaces created!"
}

# Install Istio
install_istio() {
    print_status "Installing Istio service mesh..."
    
    # Download and install Istio
    if ! command -v istioctl &> /dev/null; then
        print_status "Downloading Istio..."
        curl -L https://istio.io/downloadIstio | sh -
        export PATH=$PWD/istio-*/bin:$PATH
    fi
    
    # Install Istio with demo profile
    istioctl install --set values.defaultRevision=default -y
    
    # Enable sidecar injection for namespaces
    kubectl label namespace microservices istio-injection=enabled --overwrite
    kubectl label namespace observability istio-injection=enabled --overwrite
    
    print_success "Istio installed successfully!"
}

# Install Argo CD
install_argocd() {
    print_status "Installing Argo CD..."
    
    # Add Argo CD Helm repository
    helm repo add argo https://argoproj.github.io/argo-helm
    helm repo update
    
    # Install Argo CD
    helm upgrade --install argocd argo/argo-cd \
        --namespace argocd \
        --set server.service.type=NodePort \
        --set server.service.nodePortHttp=30080 \
        --set server.extraArgs[0]="--insecure" \
        --wait
    
    # Wait for Argo CD to be ready
    kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
    
    print_success "Argo CD installed successfully!"
}

# Install Observability Stack
install_observability() {
    print_status "Installing observability stack..."
    
    # Add Prometheus community Helm repository
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo add grafana https://grafana.github.io/helm-charts
    helm repo update
    
    # Install Prometheus
    helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
        --namespace observability \
        --set grafana.service.type=NodePort \
        --set grafana.service.nodePort=30000 \
        --set prometheus.service.type=NodePort \
        --set prometheus.service.nodePort=30090 \
        --wait
    
    # Install Jaeger
    helm repo add jaegertracing https://jaegertracing.github.io/helm-charts
    helm upgrade --install jaeger jaegertracing/jaeger \
        --namespace observability \
        --set service.type=NodePort \
        --set service.nodePort=30686 \
        --wait
    
    print_success "Observability stack installed successfully!"
}

# Install Security Tools
install_security() {
    print_status "Installing security tools..."
    
    # Install Falco
    helm repo add falcosecurity https://falcosecurity.github.io/charts
    helm upgrade --install falco falcosecurity/falco \
        --namespace security \
        --wait
    
    # Install OPA Gatekeeper
    helm repo add gatekeeper https://open-policy-agent.github.io/gatekeeper/charts
    helm upgrade --install gatekeeper gatekeeper/gatekeeper \
        --namespace security \
        --wait
    
    print_success "Security tools installed successfully!"
}

# Deploy Sample Microservices
deploy_microservices() {
    print_status "Deploying sample microservices..."
    
    # Apply microservices manifests
    kubectl apply -f manifests/microservices/ -R
    
    print_success "Microservices deployed successfully!"
}

# Setup Argo CD Applications
setup_argocd_apps() {
    print_status "Setting up Argo CD applications..."
    
    # Apply Argo CD application manifests
    kubectl apply -f argocd/applications/ -R
    
    print_success "Argo CD applications configured!"
}

# Display access information
show_access_info() {
    print_success "Deployment completed successfully!"
    echo ""
    echo "🌐 Access Information:"
    echo "====================="
    echo "Argo CD UI:     http://localhost:30080"
    echo "Grafana:        http://localhost:30000"
    echo "Jaeger:         http://localhost:30686"
    echo "Prometheus:     http://localhost:30090"
    echo ""
    echo "🔑 Argo CD Admin Password:"
    echo "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
    echo ""
    echo "📊 Sample Application:"
    echo "kubectl port-forward -n microservices svc/frontend 8081:80"
    echo "Then access: http://localhost:8081"
}

# Main deployment function
main() {
    print_status "Starting Local Kubernetes Platform deployment..."
    
    check_prerequisites
    create_namespace
    install_istio
    install_argocd
    install_observability
    install_security
    deploy_microservices
    setup_argocd_apps
    show_access_info
    
    print_success "🎉 Platform deployment completed!"
}

# Run main function
main "$@"
