# Local Kubernetes Platform with GitOps, Istio, and Observability

A comprehensive local Kubernetes platform showcasing modern cloud-native practices including GitOps with Argo CD, Istio service mesh, observability stack, and container security.

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Local Kubernetes Platform                │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │   Argo CD   │  │   Istio     │  │ Observability│        │
│  │  (GitOps)   │  │ Service Mesh│  │   Stack     │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │ Microservices│  │  Security  │  │   Storage   │        │
│  │  Application │  │   Tools    │  │  (PVCs)     │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
└─────────────────────────────────────────────────────────────┘
```

## 🚀 Features

- **GitOps**: Argo CD for declarative application deployment
- **Service Mesh**: Istio for traffic management, security, and observability
- **Observability**: Prometheus, Grafana, Loki, Jaeger/Tempo
- **Security**: Falco, OPA Gatekeeper, Pod Security Standards
- **Microservices**: Sample application with multiple services
- **Storage**: Persistent volumes for data persistence

## 📋 Prerequisites

- Docker Desktop running
- Kubernetes cluster (kind, minikube, or Docker Desktop)
- kubectl configured
- Git installed
- Helm 3.x

## 🛠️ Quick Start

1. **Clone and setup**:
   ```bash
   git clone https://github.com/Bhavesh1326/case-study.git
   cd case-study
   ```

2. **Deploy the platform**:
   ```bash
   ./scripts/deploy.sh
   ```

3. **Access services**:
   - Argo CD UI: http://localhost:8080
   - Grafana: http://localhost:3000
   - Jaeger: http://localhost:16686
   - Sample App: http://localhost:8081

## 📁 Project Structure

```
case-study/
├── argocd/                 # Argo CD configuration
├── istio/                  # Istio service mesh config
├── observability/          # Monitoring stack
├── microservices/          # Sample applications
├── security/               # Security tools and policies
├── scripts/                # Deployment scripts
├── manifests/              # Kubernetes manifests
└── docs/                   # Documentation
```

## 🔧 Components

### GitOps (Argo CD)
- Application definitions
- Sync policies
- Multi-environment support

### Service Mesh (Istio)
- Traffic management
- Security policies
- Observability integration

### Observability Stack
- **Prometheus**: Metrics collection
- **Grafana**: Dashboards and visualization
- **Loki**: Log aggregation
- **Jaeger/Tempo**: Distributed tracing

### Security
- **Falco**: Runtime security monitoring
- **OPA Gatekeeper**: Policy enforcement
- **Pod Security Standards**: Security policies

### Microservices
- Frontend (React)
- Backend API (Node.js)
- Database (PostgreSQL)
- Message Queue (Redis)

## 📊 Monitoring Dashboards

- Kubernetes cluster overview
- Istio service mesh metrics
- Application performance metrics
- Security events and alerts

## 🔒 Security Features

- Network policies
- Pod security standards
- Runtime security monitoring
- Policy enforcement
- RBAC configuration

## 📚 Documentation

- [Deployment Guide](docs/deployment.md)
- [Architecture Details](docs/architecture.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Security Guide](docs/security.md)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.
