[CmdletBinding()]
param()
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path -Parent $PSScriptRoot)
docker compose down --remove-orphans
if ($LASTEXITCODE -ne 0) { throw 'No se pudo detener la plataforma.' }

