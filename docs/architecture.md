# Arquitectura

Jenkins es el orquestador y Docker Desktop el runtime. El controlador conserva su configuración en `devsecops-jenkins-home`, carga JCasC desde un montaje de solo lectura y accede al daemon mediante el socket. La API y Jenkins comparten la red `devsecops-platform`.

```mermaid
flowchart TB
  subgraph Windows["Windows + Docker Desktop WSL2"]
    subgraph Net["Red devsecops-platform"]
      J["Jenkins LTS\nJCasC + plugins"]
      A["devops-demo-api\nusuario 10001"]
    end
    V[("jenkins_home")]
    D["Docker daemon"]
    J --- V
    J --> D --> A
  end
  GH["GitHub"] --> J
  J -. "PUBLISH_IMAGE=true" .-> CR["GHCR"]
```

El montaje del socket concede control elevado sobre Docker; es una decisión local documentada en ADR-001, no un patrón recomendado para producción.

