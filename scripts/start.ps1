[CmdletBinding()]
param([switch]$WithApp)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path -Parent $PSScriptRoot)

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) { throw 'Docker CLI no está instalado o no está en PATH.' }
docker info *> $null
if ($LASTEXITCODE -ne 0) { throw 'Docker Desktop no está disponible. Inícielo y vuelva a intentar.' }
docker compose version *> $null
if ($LASTEXITCODE -ne 0) { throw 'Docker Compose no está disponible.' }
if (-not (Test-Path '.env')) { throw 'Falta .env. Copie .env.example a .env y reemplace CHANGE_ME.' }
if (Select-String -Path '.env' -Pattern 'CHANGE_ME' -Quiet) { throw 'El archivo .env todavía contiene valores CHANGE_ME.' }

$arguments = @('compose')
if ($WithApp) { $arguments += @('--profile', 'app') }
$arguments += @('up', '-d', '--build')
& docker @arguments
if ($LASTEXITCODE -ne 0) { throw 'No se pudo iniciar la plataforma.' }
docker compose ps
