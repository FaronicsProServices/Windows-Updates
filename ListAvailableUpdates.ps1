# It uses Windows Updates API to fetch if any updates are available for the current device
# Create an update session object
$updateSession = New-Object -ComObject Microsoft.Update.Session

# Create an update searcher object
$updateSearcher = $updateSession.CreateUpdateSearcher()

# Search for available updates
$searchResult = $updateSearcher.Search("IsInstalled=0")

# List available updates
if ($searchResult.Updates.Count -gt 0) {
    Write-Host "The following updates are available for this computer:" -ForegroundColor Green
    $searchResult.Updates | ForEach-Object { Write-Host $_.Title }
} else {
    Write-Host "No updates are available." -ForegroundColor Red
}
