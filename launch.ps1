# Enterprise Serverless Platform - Local Launch Script

Write-Host "🚀 Preparing to launch Enterprise Serverless Platform..." -ForegroundColor Cyan

# 1. Attempt to start Docker Compose
Write-Host "📦 Starting services via Docker Compose..." -ForegroundColor Yellow
docker-compose up -d --build

# 2. Simulated Startup Progress
Write-Host "⏳ Initializing Database and API..." -ForegroundColor Yellow
Start-Sleep -s 5

# 3. Final URL Display
Write-Host "`n✅ Local Platform is Initialized!" -ForegroundColor Green
Write-Host "--------------------------------------------------" -ForegroundColor White
Write-Host "🌍 Web API Host:    http://localhost:8080" -ForegroundColor White
Write-Host "🏥 Health Check:    http://localhost:8080/health" -ForegroundColor White
Write-Host "📦 API Items:       http://localhost:8080/items" -ForegroundColor White
Write-Host "--------------------------------------------------" -ForegroundColor White

Write-Host "`nTo view real-time logs: docker-compose logs -f app" -ForegroundColor Gray
