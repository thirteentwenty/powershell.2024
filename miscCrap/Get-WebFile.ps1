param (
    [string]$Filename
)

$server = "https://dlc.cetra.us/"
$webFile = $server + $($Filename)

function Get-FileSize {
    $fileSizeInBytes = [math]::Round((Invoke-WebRequest $($webFile) -Method Head).Headers.'Content-Length',2)

    If (($fileSizeInBytes -ge 1TB)) {
        return "{0:N2} TB" -f ($fileSizeInBytes / 1TB)
    } elseif ($fileSizeInBytes -ge 1GB) {
        return "{0:N2} GB" -f ($fileSizeInBytes / 1GB)
    } elseif ($fileSizeInBytes -ge 1MB) {
        return "{0:N2} MB" -f ($fileSizeInBytes / 1MB)
    } else {
        Write-Host $($fileSizeInBytes)
    }
}

try {
    Get-FileSize -ErrorAction SilentlyContinue
    Write-Host $Filename
} catch {
    if ($_.Exception.Response.StatusCode.Value__ -eq "404") {
        Write-Host File not found check the file name
    }
} 
