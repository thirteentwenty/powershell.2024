param (
    [string]$Filename
)
Clear-Host
$server = "https://some.domain.tld/"
$saveLocation = "C:\Users\Someone\Some\Folder\"
$webFile = $server + $($Filename)
$date = (Get-Date -f 'yyyy.MM.dd-HHmm')
$file = $Filename.split(".")
$name = $file[0]
$ext = $file[1]
$fname = $file[0] + "_" + $date + "." + $file[1]


function Get-FileSize {
    $fileSizeInBytes = [math]::Round((Invoke-WebRequest $($webFile) -Method Head).Headers.'Content-Length',2)

    If (($fileSizeInBytes -ge 1TB)) {
        return "Download size {0:N2} TB" -f ($fileSizeInBytes / 1TB)
    } elseif ($fileSizeInBytes -ge 1GB) {
        return "Download size {0:N2} GB" -f ($fileSizeInBytes / 1GB)
    } elseif ($fileSizeInBytes -ge 1MB) {
        return "Download size {0:N2} MB" -f ($fileSizeInBytes / 1MB)
    } else {
        Write-Host $($fileSizeInBytes)
    }
}

try {
    Write-Host ""
    Write-Host ""
    Write-Host ""
    Write-Host ""
    Write-Host ""
    Write-Host ""
    Write-Host ""
    Get-FileSize -ErrorAction SilentlyContinue
    Write-Host Saving $Filename to $saveLocation
    Invoke-WebRequest -Uri $($webFile) -Outfile $saveLocation$fname
} catch {
    if ($_.Exception.Response.StatusCode.Value__ -eq "404") {
        Write-Host File not found check the file name
    }
} 
