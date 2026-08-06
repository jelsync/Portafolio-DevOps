# Instalación

## PowerShell local

1. Inicie Docker Desktop y espere a que el motor indique Running.
2. Entre en la raíz del repositorio.
3. Ejecute `Copy-Item .env.example .env`.
4. Edite `.env`; no reutilice credenciales reales.
5. Ejecute `./scripts/validate.ps1` y luego `./scripts/start.ps1`.
6. Consulte `docker compose ps` y `http://localhost:8081`.

Validación completa desde **PowerShell local**:

```powershell
docker version
docker compose version
docker compose --env-file .env config
docker compose build
docker compose up -d
docker compose ps
docker compose --profile app up -d --build app
```

En **WSL**, los equivalentes son `docker version`, `docker compose version` y `docker compose up -d --build`; ejecute desde `/mnt/c/.../DEVOPS`. No hay comandos obligatorios dentro del contenedor Jenkins. En la **interfaz web de GitHub**, configure webhooks/credenciales solo en una fase autorizada.

Maven local es opcional. Si está instalado, desde `app/devops-demo-api` ejecute `mvn clean test` y `mvn clean package`; de lo contrario use `docker build -t local/devops-demo-api:test .`.

