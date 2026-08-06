[CmdletBinding()]
param()
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path -Parent $PSScriptRoot)
docker compose ps
if ($LASTEXITCODE -ne 0) { throw 'No se pudo consultar el estado.' }

