# ADR-001: plataforma Jenkins local

- Estado: aceptada para MVP
- Fecha: 2026-08-05

## Contexto

El portafolio debe ser reproducible en Windows/Docker Desktop, sin Kubernetes, EKS ni costos AWS.

## Decisión

Ejecutar Jenkins LTS/JDK 17 con Docker Compose, JCasC, plugins fijados y volumen persistente. Jenkins usa el socket Docker para construir y desplegar. La API corre sin root. Los scanners se ejecutan como contenedores versionados. GHCR y SonarQube son opcionales.

## Consecuencias

El arranque y destrucción son simples y no generan costos cloud. El socket amplía privilegios y el controlador ejecuta como root, aceptable solo en una estación local aislada. Producción debe usar agentes efímeros aislados, secretos administrados y políticas más estrictas.

