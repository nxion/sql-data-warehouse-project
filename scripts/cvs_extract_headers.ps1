# CSV Header Extractor
# This script reads a CSV file and displays its headers
# To run it use the following syntax method:
#
#     .\Get-CSVHeaders.ps1 -FilePath "C:\path\to\your\file.csv"
#


param(
    [Parameter(Mandatory=$true)]
    [string]$FilePath
)

# Check if file exists
if (-not (Test-Path -Path $FilePath -PathType Leaf)) {
    Write-Error "The specified file does not exist: $FilePath"
    exit 1
}

# Check if file is a CSV
if (-not $FilePath.EndsWith('.csv', [StringComparison]::OrdinalIgnoreCase)) {
    Write-Warning "The specified file may not be a CSV file: $FilePath"
}

try {
    # Read the first line of the CSV file (headers)
    $headers = (Get-Content -Path $FilePath -TotalCount 1).Split(',')
    
    # Display the headers
    Write-Host "Headers found in the CSV file:" -ForegroundColor Green
    for ($i = 0; $i -lt $headers.Count; $i++) {
        # Trim any quotes and whitespace from headers
        $header = $headers[$i].Trim('"', ' ')
        Write-Host "  $($i+1). $header"
    }
    
    Write-Host "`nTotal number of headers: $($headers.Count)" -ForegroundColor Cyan
}
catch {
    Write-Error "An error occurred while processing the file: $_"
    exit 1
}