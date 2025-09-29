#!/bin/bash

# Kubernetes Cluster Setup Script
# Supports kind, minikube, and Docker Desktop

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Detect cluster type
detect_cluster() {
    if command -v kind &> /dev/null && kind get clusters &> /dev/null; then
        echo "kind"
    elif command -v minikube &> /dev/null && minikube status &> /dev/null; then
        echo "minikube"
    elif kubectl config current-context | grep -q "docker-desktop"; then
        echo "docker-desktop"
    else
        echo "unknown"
    fi
}

# Setup kind cluster
setup_kind() {
    print_status "Setting up kind cluster..."
    
    # Create kind cluster configuration
    cat > kind-config.yaml << EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: case-study-cluster
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
  - containerPort: 30000
    hostPort: 30000
    protocol: TCP
  - containerPort: 30080
    hostPort: 30080
    protocol: TCP
  - containerPort: 30686
    hostPort: 30686
    protocol: TCP
  - containerPort: 30090
    hostPort: 30090
    protocol: TCP
- role: worker
- role: worker
EOF

    # Create the cluster
    kind create cluster --config=kind-config.yaml
    
    # Wait for cluster to be ready
    kubectl wait --for=condition=Ready nodes --all --timeout=300s
    
    print_success "kind cluster created successfully!"
}

# Setup minikube cluster
setup_minikube() {
    print_status "Setting up minikube cluster..."
    
    # Start minikube with required resources
    minikube start \
        --memory=8192 \
        --cpus=4 \
        --disk-size=20g \
        --driver=docker \
        --ports=80:80,443:443,30000:30000,30080:30080,30686:30686,30090:30090
    
    # Enable required addons
    minikube addons enable metrics-server
    minikube addons enable ingress
    
    print_success "minikube cluster started successfully!"
}

# Setup Docker Desktop
setup_docker_desktop() {
    print_status "Using Docker Desktop Kubernetes..."
    
    # Check if Docker Desktop Kubernetes is enabled
    if ! kubectl cluster-info &> /dev/null; then
        print_error "Docker Desktop Kubernetes is not enabled. Please enable it in Docker Desktop settings."
        exit 1
    fi
    
    print_success "Docker Desktop Kubernetes is ready!"
}

# Install NGINX Ingress Controller
install_ingress() {
    print_status "Installing NGINX Ingress Controller..."
    
    # Install NGINX Ingress Controller
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
    
    # Wait for ingress controller to be ready
    kubectl wait --namespace ingress-nginx \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/component=controller \
        --timeout=300s
    
    print_success "NGINX Ingress Controller installed!"
}

# Main setup function
main() {
    print_status "Setting up Kubernetes cluster..."
    
    CLUSTER_TYPE=$(detect_cluster)
    
    case $CLUSTER_TYPE in
        "kind")
            setup_kind
            ;;
        "minikube")
            setup_minikube
            ;;
        "docker-desktop")
            setup_docker_desktop
            ;;
        *)
            print_error "No supported Kubernetes cluster detected."
            print_status "Please install one of the following:"
            echo "  - kind: https://kind.sigs.k8s.io/docs/user/quick-start/"
            echo "  - minikube: https://minikube.sigs.k8s.io/docs/start/"
            echo "  - Docker Desktop with Kubernetes enabled"
            exit 1
            ;;
    esac
    
    install_ingress
    
    print_success "Kubernetes cluster setup completed!"
    print_status "Cluster type: $CLUSTER_TYPE"
    print_status "Context: $(kubectl config current-context)"
}

# Run main function
main "$@"
