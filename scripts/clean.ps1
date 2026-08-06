[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
param([switch]$Volumes)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path -Parent $PSScriptRoot)

if ($Volumes) {
    if ($PSCmdlet.ShouldProcess('contenedores y volúmenes persistentes de la plataforma', 'Eliminar')) {
        docker compose down --volumes --remove-orphans
    }
} else {
    docker compose down --remove-orphans
}
if ($LASTEXITCODE -ne 0) { throw 'La limpieza no terminó correctamente.' }

