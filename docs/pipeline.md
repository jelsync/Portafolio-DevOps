# Pipeline

```mermaid
flowchart LR
  C["Checkout"] --> V["Validate"] --> B["Compile"] --> U["Unit Tests"] --> P["Package"]
  P --> G["Gitleaks"] --> D["Dependency Scan"] --> S["Static Analysis"]
  S --> I["Docker Build"] --> T["Container Scan"] --> O{"Publish?"}
  O -->|"opcional"| R["GHCR"]
  O --> L["Deploy Local"] --> H["Health Check"] --> M["Smoke Tests"] --> E["Reports"]
```

Cada comando termina con código distinto de cero ante un fallo bloqueante y Jenkins muestra el stage. JUnit publica XML aunque fallen las pruebas. `post.always` archiva evidencia, elimina el contenedor temporal y limpia el workspace.

```mermaid
sequenceDiagram
  actor Dev as Desarrollador
  participant Git as GitHub
  participant J as Jenkins
  participant Sec as Scanners
  participant Docker as Docker Desktop
  Dev->>Git: push autorizado
  Git->>J: trigger o ejecución manual
  J->>Git: checkout
  J->>J: compile + tests + package
  J->>Sec: Gitleaks + Dependency-Check + Trivy
  Sec-->>J: reportes y gates
  J->>Docker: build con tag inmutable
  J->>Docker: run + health + smoke tests
  J-->>Dev: estado y evidencias
```

