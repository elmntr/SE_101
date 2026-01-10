# Auto Test Runner for Flutter Tests
# This script automatically runs flutter test every 30 seconds

Write-Host "🚀 Starting Auto Test Runner..." -ForegroundColor Green
Write-Host "📊 Running flutter test every 30 seconds..." -ForegroundColor Yellow
Write-Host "🛑 Press Ctrl+C to stop" -ForegroundColor Red
Write-Host ""

$counter = 1

while ($true) {
    Write-Host "🔄 Test Run #$counter - $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Cyan
    Write-Host "------------------------------------------------" -ForegroundColor Gray
    
    $startTime = Get-Date
    
    # Run flutter test
    flutter test --reporter=compact
    
    $endTime = Get-Date
    $duration = $endTime - $startTime
    
    Write-Host ""
    Write-Host "✅ Test Run #$counter completed in $($duration.TotalSeconds) seconds" -ForegroundColor Green
    Write-Host "⏳ Waiting 30 seconds before next run..." -ForegroundColor Yellow
    Write-Host ""
    
    $counter++
    
    # Wait 30 seconds
    Start-Sleep -Seconds 30
}
