# Solución de problemas

- **Docker pipe access denied:** inicie/reinicie Docker Desktop, confirme el contexto con `docker context show` y ejecute `docker version` en PowerShell local.
- **Permiso en `.docker/config.json`:** revise propietario/ACL del archivo desde Windows; no lo borre sin respaldo.
- **Jenkins unhealthy:** ejecute `./scripts/logs.ps1`; la instalación inicial de plugins puede tardar varios minutos.
- **Puerto ocupado:** cambie `JENKINS_HTTP_PORT` o `APP_HTTP_PORT` en `.env` y recree los servicios.
- **Job no encuentra `main`:** el repositorio local aún no se publicó. Configure `GIT_REPOSITORY_URL` y rama después de autorizar commit/push.
- **Dependency-Check lento:** espere la descarga inicial, añada caché/NVD API key como credencial en otra fase o desactive temporalmente el parámetro dejando constancia.
- **Contenedor no saludable:** `docker logs devops-demo-api` y `Invoke-RestMethod http://localhost:8080/actuator/health`.
- **Puerto 8080 ocupado al ejecutar el pipeline:** detenga primero el servicio Compose de prueba con `docker compose --profile app stop app`; el despliegue del pipeline publica ese mismo puerto.
- **JCasC falla:** valide indentación y variables `.env`; consulte `docker compose logs jenkins`.

Para revertir cambios operativos, use `./scripts/stop.ps1`. Para volver a estado limpio conservando código, `./scripts/clean.ps1 -Volumes` y confirme; esto elimina irreversiblemente la configuración persistente de Jenkins.
