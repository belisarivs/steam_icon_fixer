# Get the desktop path
$desktopPath = [Environment]::GetFolderPath("Desktop")

# Get all .url files on the desktop
$urlFiles = Get-ChildItem -Path $desktopPath -Filter "*.url"

foreach ($urlFile in $urlFiles) {
    # Read the .url file content
    $urlContent = Get-Content $urlFile.FullName

    # Extract game ID from the URL line
    $gameId = ($urlContent | Select-String -Pattern "URL=steam://rungameid/(\d+)").Matches.Groups[1].Value

    # Extract client icon hash and full path from IconFile line
    $iconFileLine = ($urlContent | Select-String -Pattern "IconFile=(.+\.ico)").Matches.Groups[1].Value
    $clientIcon = ($iconFileLine | Select-String -Pattern "\\([a-f0-9]+)\.ico").Matches.Groups[1].Value

    if ($gameId -and $clientIcon) {
        # Construct the CDN URL
        $iconUrl = "https://cdn.cloudflare.steamstatic.com/steamcommunity/public/images/apps/$gameId/$clientIcon.ico"
        Write-Host "`n$($urlFile.Name)"
        Write-Host "Icon URL: $iconUrl"
        Write-Host "Save Location: $iconFileLine"
        
        try {
            # Create directory if it doesn't exist
            $iconDirectory = Split-Path -Parent $iconFileLine
            
            if (!(Test-Path $iconDirectory)) {
                Write-Host "Creating directory..."
                New-Item -ItemType Directory -Path $iconDirectory -Force | Out-Null
            }

            # Download the icon
            Invoke-WebRequest -Uri $iconUrl -OutFile $iconFileLine
            Write-Host "Icon downloaded successfully"
        }
        catch {
            Write-Host "Failed to download icon: $_"
        }
    } else {
        Write-Host "`n$($urlFile.Name)"
        Write-Host "Could not extract required information from this .url file"
    }
}
