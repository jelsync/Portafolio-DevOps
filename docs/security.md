# Seguridad

## Política del MVP

| Control | Evidencia | Gate |
|---|---|---|
| Gitleaks | JSON redactado | Cualquier secreto confirmado |
| Dependency-Check | HTML/JSON/JUnit | CVSS 9.0 o superior |
| Trivy config | JSON | CRITICAL |
| Trivy image | JSON + consola | CRITICAL corregible; HIGH advertencia |

Un `HIGH` sigue visible para facilitar el laboratorio inicial. Un `CRITICAL` no corregido puede aceptarse temporalmente solo mediante una excepción revisada y documentada; no se agrega una excepción silenciosa al pipeline. Riesgo: ejecución de código, fuga de datos o compromiso de la cadena. Recomendación: actualizar/eliminar el componente, reconstruir y volver a escanear.

`.env.example` contiene solo marcadores. `.env`, llaves y keystores están ignorados. GHCR usa Jenkins Credentials y enmascaramiento de logs. El socket Docker concede privilegios equivalentes al daemon: no exponga Jenkins a redes no confiables y migre a agentes aislados para producción.

Dependency-Check puede tardar o sufrir límites de NVD en la primera ejecución. Configure una API key de NVD como credencial de Jenkins en una siguiente iteración; nunca en el repositorio. `RUN_SECURITY_SCAN=false` existe para diagnóstico explícito, no como estado de entrega.

Durante la validación del MVP, Trivy detectó tres CVE críticas corregibles en Tomcat 10.1.42. Se actualizó Spring Boot a 3.5.13 y se fijó Tomcat 10.1.55; la reconstrucción conservó las cuatro pruebas exitosas y el reescaneo redujo el resultado a cero vulnerabilidades `CRITICAL`. Los hallazgos `HIGH` continúan visibles en el JSON para remediación progresiva.
