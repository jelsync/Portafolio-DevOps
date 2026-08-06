[CmdletBinding()]
param()
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path -Parent $PSScriptRoot)

$failures = [System.Collections.Generic.List[string]]::new()
foreach ($command in @('docker', 'git')) {
    if (-not (Get-Command $command -ErrorAction SilentlyContinue)) { $failures.Add("No se encontró $command en PATH.") }
}
if ($failures.Count -eq 0) {
    docker version
    if ($LASTEXITCODE -ne 0) { $failures.Add('Docker Engine no está disponible.') }
    docker compose version
    if ($LASTEXITCODE -ne 0) { $failures.Add('Docker Compose no está disponible.') }
    if (Test-Path '.env') { docker compose config --quiet } else { docker compose --env-file .env.example config --quiet }
    if ($LASTEXITCODE -ne 0) { $failures.Add('docker compose config no es válido.') }
}
$trackedSensitive = git ls-files | Select-String -Pattern '(^|/)(\.env|.*\.(pem|key|p12|jks))$'
if ($trackedSensitive) { $failures.Add("Se detectaron archivos sensibles versionados: $trackedSensitive") }
if ($failures.Count -gt 0) { throw ($failures -join [Environment]::NewLine) }
Write-Host 'Validación estática completada correctamente.' -ForegroundColor Green

