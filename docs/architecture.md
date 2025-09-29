# Architecture Documentation

## Overview

This Local Kubernetes Platform demonstrates modern cloud-native practices with a comprehensive stack including GitOps, service mesh, observability, and security tools.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           Local Kubernetes Platform                            │
├─────────────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐                │
│  │   GitOps Layer  │  │  Service Mesh   │  │ Observability   │                │
│  │                 │  │                 │  │     Stack       │                │
│  │  ┌─────────────┐│  │  ┌─────────────┐│  │  ┌─────────────┐│                │
│  │  │  Argo CD    ││  │  │    Istio    ││  │  │ Prometheus  ││                │
│  │  │  (GitOps)   ││  │  │ (Service    ││  │  │             ││                │
│  │  └─────────────┘│  │  │   Mesh)     ││  │  └─────────────┘│                │
│  │                 │  │  └─────────────┘│  │  ┌─────────────┐│                │
│  │  ┌─────────────┐│  │                 │  │  │   Grafana   ││                │
│  │  │ Applications││  │  ┌─────────────┐│  │  │             ││                │
│  │  │             ││  │  │  Ingress    ││  │  └─────────────┘│                │
│  │  └─────────────┘│  │  │  Gateway    ││  │  ┌─────────────┐│                │
│  └─────────────────┘  │  └─────────────┘│  │  │   Jaeger    ││                │
│                       └─────────────────┘  │  │  (Tracing)  ││                │
│                                            │  └─────────────┘│                │
├─────────────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐                │
│  │  Microservices  │  │   Security      │  │    Storage      │                │
│  │   Application   │  │     Layer       │  │   (PVCs)        │                │
│  │                 │  │                 │  │                 │                │
│  │  ┌─────────────┐│  │  ┌─────────────┐│  │  ┌─────────────┐│                │
│  │  │  Frontend   ││  │  │    Falco    ││  │  │ PostgreSQL  ││                │
│  │  │  (React)    ││  │  │ (Runtime    ││  │  │   Storage   ││                │
│  │  └─────────────┘│  │  │ Security)   ││  │  └─────────────┘│                │
│  │  ┌─────────────┐│  │  └─────────────┘│  │  ┌─────────────┐│                │
│  │  │  Backend    ││  │  ┌─────────────┐│  │  │    Redis    ││                │
│  │  │  (Node.js)  ││  │  │    OPA      ││  │  │   Storage   ││                │
│  │  └─────────────┘│  │  │ Gatekeeper  ││  │  └─────────────┘│                │
│  │  ┌─────────────┐│  │  │ (Policy     ││  │                 │                │
│  │  │ PostgreSQL  ││  │  │ Enforcement)││  │                 │                │
│  │  └─────────────┘│  │  └─────────────┘│  │                 │                │
│  │  ┌─────────────┐│  │  ┌─────────────┐│  │                 │                │
│  │  │    Redis    ││  │  │  Network    ││  │                 │                │
│  │  │  (Cache)    ││  │  │  Policies   ││  │                 │                │
│  │  └─────────────┘│  │  └─────────────┘│  │                 │                │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘                │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## Component Details

### 1. GitOps Layer (Argo CD)

**Purpose**: Declarative application deployment and management

**Components**:
- Argo CD Server
- Argo CD Application Controller
- Argo CD Repo Server
- Argo CD Dex Server

**Features**:
- Continuous synchronization with Git repositories
- Automated deployment of applications
- Rollback capabilities
- Multi-environment support
- RBAC integration

**Configuration**:
- Repository: GitHub (https://github.com/Bhavesh1326/case-study.git)
- Sync Policy: Automated with self-healing
- Namespace: `argocd`

### 2. Service Mesh (Istio)

**Purpose**: Traffic management, security, and observability

**Components**:
- Istiod (Control Plane)
- Istio Ingress Gateway
- Istio Egress Gateway
- Envoy Sidecar Proxies

**Features**:
- Traffic routing and load balancing
- Security policies (mTLS, RBAC)
- Observability (metrics, logs, traces)
- Circuit breakers and retries
- Canary deployments

**Configuration**:
- Profile: `demo`
- Ingress Gateway: NodePort (30080, 30443)
- Sidecar injection: Enabled for `microservices` and `observability` namespaces

### 3. Observability Stack

#### Prometheus
- **Purpose**: Metrics collection and storage
- **Features**: Service discovery, alerting, querying
- **Access**: http://localhost:30090

#### Grafana
- **Purpose**: Visualization and dashboards
- **Features**: Pre-built dashboards, alerting, data sources
- **Access**: http://localhost:30000
- **Default Credentials**: admin/admin123

#### Jaeger
- **Purpose**: Distributed tracing
- **Features**: Request tracing, service dependency mapping
- **Access**: http://localhost:30686

### 4. Microservices Application

#### Frontend Service
- **Technology**: Nginx with custom HTML/JS
- **Purpose**: User interface
- **Port**: 80
- **Features**: API integration, responsive design

#### Backend Service
- **Technology**: Node.js with Express
- **Purpose**: API server
- **Port**: 8080
- **Features**: REST API, health checks, logging

#### Database Services
- **PostgreSQL**: Primary database
- **Redis**: Caching and session storage
- **Persistence**: PVCs with 10Gi and 5Gi respectively

### 5. Security Layer

#### Falco
- **Purpose**: Runtime security monitoring
- **Features**: Threat detection, policy enforcement, alerting
- **Rules**: Custom rules for container security

#### OPA Gatekeeper
- **Purpose**: Policy enforcement
- **Features**: Admission control, policy validation
- **Policies**: Resource limits, security context, labels

#### Network Policies
- **Purpose**: Network segmentation
- **Features**: Ingress/egress control, pod-to-pod communication

## Data Flow

### 1. User Request Flow
```
User → Istio Ingress Gateway → Frontend Service → Backend Service → Database
```

### 2. Observability Flow
```
Services → Envoy Sidecar → Prometheus → Grafana
Services → Envoy Sidecar → Jaeger
Services → Falco → Security Alerts
```

### 3. GitOps Flow
```
Git Repository → Argo CD → Kubernetes API → Deployed Applications
```

## Security Considerations

### 1. Network Security
- Network policies restrict pod-to-pod communication
- Istio mTLS encrypts service-to-service communication
- Ingress gateway provides secure external access

### 2. Runtime Security
- Falco monitors container behavior
- OPA Gatekeeper enforces admission policies
- Pod Security Standards ensure secure container execution

### 3. Data Security
- Persistent volumes for data persistence
- Secrets management through Kubernetes secrets
- RBAC for access control

## Scalability

### 1. Horizontal Scaling
- All services support horizontal pod autoscaling
- Istio load balancing across service instances
- Database clustering (PostgreSQL)

### 2. Resource Management
- Resource requests and limits defined
- Quality of Service (QoS) classes
- Node affinity and anti-affinity rules

### 3. Storage Scaling
- Dynamic volume provisioning
- Storage classes for different performance tiers
- Volume expansion capabilities

## Monitoring and Alerting

### 1. Metrics
- Kubernetes cluster metrics
- Application performance metrics
- Istio service mesh metrics
- Security event metrics

### 2. Dashboards
- Cluster overview dashboard
- Istio service mesh dashboard
- Application performance dashboard
- Security events dashboard

### 3. Alerts
- Resource utilization alerts
- Service health alerts
- Security incident alerts
- Performance degradation alerts

## Backup and Recovery

### 1. Data Backup
- PostgreSQL database backups
- Redis data persistence
- Configuration backup (Git)

### 2. Disaster Recovery
- Multi-node cluster support
- Persistent volume replication
- Application state recovery

## Performance Optimization

### 1. Resource Optimization
- CPU and memory limits
- Storage optimization
- Network optimization

### 2. Caching
- Redis for application caching
- Istio caching for service mesh
- Grafana dashboard caching

### 3. Load Balancing
- Istio load balancing
- Kubernetes service load balancing
- Ingress load balancing

## Troubleshooting

### 1. Common Issues
- Pod startup failures
- Service connectivity issues
- Resource constraints
- Configuration errors

### 2. Debugging Tools
- kubectl commands
- Istio debugging tools
- Prometheus queries
- Jaeger traces

### 3. Log Analysis
- Centralized logging
- Log aggregation
- Error pattern analysis
