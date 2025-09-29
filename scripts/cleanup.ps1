# Cleanup Script for Local Kubernetes Platform
# This script removes all components and cleans up the environment

param(
    [switch]$Force,
    [switch]$SkipConfirmation
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

# Confirmation prompt
function Confirm-Cleanup {
    if ($SkipConfirmation) {
        return $true
    }
    
    $response = Read-Host "Are you sure you want to delete all platform components? This action cannot be undone. (y/N)"
    return $response -eq 'y' -or $response -eq 'Y'
}

# Delete Argo CD applications
function Remove-ArgoCDApplications {
    Write-Status "Removing Argo CD applications..."
    
    try {
        kubectl delete applications --all -n argocd --ignore-not-found=true
        Write-Success "Argo CD applications removed"
    }
    catch {
        Write-Warning "Failed to remove some Argo CD applications: $_"
    }
}

# Delete microservices
function Remove-Microservices {
    Write-Status "Removing microservices..."
    
    try {
        kubectl delete -f microservices/manifests/ -R --ignore-not-found=true
        kubectl delete -f manifests/ -R --ignore-not-found=true
        Write-Success "Microservices removed"
    }
    catch {
        Write-Warning "Failed to remove some microservices: $_"
    }
}

# Delete observability stack
function Remove-ObservabilityStack {
    Write-Status "Removing observability stack..."
    
    try {
        helm uninstall prometheus -n observability --ignore-not-found=true
        helm uninstall jaeger -n observability --ignore-not-found=true
        Write-Success "Observability stack removed"
    }
    catch {
        Write-Warning "Failed to remove observability stack: $_"
    }
}

# Delete security tools
function Remove-SecurityTools {
    Write-Status "Removing security tools..."
    
    try {
        helm uninstall falco -n security --ignore-not-found=true
        helm uninstall gatekeeper -n security --ignore-not-found=true
        Write-Success "Security tools removed"
    }
    catch {
        Write-Warning "Failed to remove security tools: $_"
    }
}

# Delete Argo CD
function Remove-ArgoCD {
    Write-Status "Removing Argo CD..."
    
    try {
        helm uninstall argocd -n argocd --ignore-not-found=true
        Write-Success "Argo CD removed"
    }
    catch {
        Write-Warning "Failed to remove Argo CD: $_"
    }
}

# Delete Istio
function Remove-Istio {
    Write-Status "Removing Istio..."
    
    try {
        if (Get-Command istioctl -ErrorAction SilentlyContinue) {
            istioctl uninstall --purge -y
            Write-Success "Istio removed"
        }
        else {
            Write-Warning "istioctl not found, skipping Istio removal"
        }
    }
    catch {
        Write-Warning "Failed to remove Istio: $_"
    }
}

# Delete namespaces
function Remove-Namespaces {
    Write-Status "Removing namespaces..."
    
    $namespaces = @("microservices", "observability", "security", "argocd", "istio-system")
    
    foreach ($ns in $namespaces) {
        try {
            kubectl delete namespace $ns --ignore-not-found=true
            Write-Success "Namespace $ns removed"
        }
        catch {
            Write-Warning "Failed to remove namespace $ns : $_"
        }
    }
}

# Clean up persistent volumes
function Remove-PersistentVolumes {
    Write-Status "Removing persistent volumes..."
    
    try {
        kubectl delete pv --all --ignore-not-found=true
        Write-Success "Persistent volumes removed"
    }
    catch {
        Write-Warning "Failed to remove persistent volumes: $_"
    }
}

# Clean up Helm repositories
function Remove-HelmRepositories {
    Write-Status "Removing Helm repositories..."
    
    $repos = @(
        "argo",
        "prometheus-community", 
        "grafana",
        "jaegertracing",
        "falcosecurity",
        "gatekeeper"
    )
    
    foreach ($repo in $repos) {
        try {
            helm repo remove $repo --ignore-not-found=true
            Write-Success "Helm repository $repo removed"
        }
        catch {
            Write-Warning "Failed to remove Helm repository $repo : $_"
        }
    }
}

# Clean up local files
function Remove-LocalFiles {
    Write-Status "Removing local files..."
    
    $filesToRemove = @(
        "istio-*",
        "kind-config.yaml",
        "*.log"
    )
    
    foreach ($pattern in $filesToRemove) {
        try {
            Get-ChildItem -Path . -Name $pattern -Recurse | Remove-Item -Force -Recurse
            Write-Success "Local files matching $pattern removed"
        }
        catch {
            Write-Warning "Failed to remove files matching $pattern : $_"
        }
    }
}

# Main cleanup function
function Main {
    Write-Status "Starting cleanup of Local Kubernetes Platform..."
    
    if (-not (Confirm-Cleanup)) {
        Write-Status "Cleanup cancelled by user"
        return
    }
    
    Write-Warning "This will remove all platform components. This action cannot be undone."
    
    if (-not $Force) {
        $confirm = Read-Host "Type 'DELETE' to confirm cleanup"
        if ($confirm -ne 'DELETE') {
            Write-Status "Cleanup cancelled - confirmation not provided"
            return
        }
    }
    
    # Remove components in reverse order
    Remove-ArgoCDApplications
    Remove-Microservices
    Remove-ObservabilityStack
    Remove-SecurityTools
    Remove-ArgoCD
    Remove-Istio
    Remove-Namespaces
    Remove-PersistentVolumes
    Remove-HelmRepositories
    Remove-LocalFiles
    
    Write-Success "🎉 Cleanup completed successfully!"
    Write-Status "All platform components have been removed"
    Write-Status "You can now run the deployment script again to recreate the platform"
}

# Run main function
Main
