# Traffic Generation Script for Microservices
# This script generates traffic to populate Grafana dashboards

Write-Host "Starting traffic generation for microservices..." -ForegroundColor Green
Write-Host "This will generate traffic to populate Istio and microservices metrics in Grafana" -ForegroundColor Yellow
Write-Host "Press Ctrl+C to stop" -ForegroundColor Red
Write-Host ""

$frontend_url = "http://localhost:8081"
$backend_url = "http://localhost:8080"

$request_count = 0

try {
    while ($true) {
        $request_count++
        
        # Generate frontend requests
        try {
            $response = Invoke-WebRequest -Uri $frontend_url -UseBasicParsing -TimeoutSec 5
            Write-Host "[$request_count] Frontend request: $($response.StatusCode)" -ForegroundColor Green
        }
        catch {
            Write-Host "[$request_count] Frontend request failed: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        # Generate backend API requests
        try {
            $response = Invoke-WebRequest -Uri "$backend_url/health" -UseBasicParsing -TimeoutSec 5
            Write-Host "[$request_count] Backend health: $($response.StatusCode)" -ForegroundColor Cyan
        }
        catch {
            Write-Host "[$request_count] Backend health failed: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        try {
            $response = Invoke-WebRequest -Uri "$backend_url/api/users" -UseBasicParsing -TimeoutSec 5
            Write-Host "[$request_count] Backend users: $($response.StatusCode)" -ForegroundColor Cyan
        }
        catch {
            Write-Host "[$request_count] Backend users failed: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        # Wait 2 seconds between requests
        Start-Sleep -Seconds 2
        
        # Show progress every 10 requests
        if ($request_count % 10 -eq 0) {
            Write-Host "Generated $request_count requests so far..." -ForegroundColor Yellow
            Write-Host "Check Grafana at http://localhost:30300 for metrics!" -ForegroundColor Magenta
        }
    }
}
catch {
    Write-Host "`nTraffic generation stopped after $request_count requests" -ForegroundColor Yellow
    Write-Host "Check your Grafana dashboards now!" -ForegroundColor Green
}