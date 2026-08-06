[CmdletBinding()]
param([ValidateSet('jenkins','app')][string]$Service = 'jenkins', [int]$Tail = 200)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path -Parent $PSScriptRoot)
docker compose logs --tail $Tail --follow $Service
if ($LASTEXITCODE -ne 0) { throw "No se pudieron consultar los logs de $Service." }

