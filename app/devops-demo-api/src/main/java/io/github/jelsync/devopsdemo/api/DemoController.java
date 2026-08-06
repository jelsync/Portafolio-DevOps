package io.github.jelsync.devopsdemo.api;

import java.time.Instant;
import java.util.Map;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api")
public class DemoController {
    private final String version;

    public DemoController(@Value("${app.version:dev}") String version) {
        this.version = version;
    }

    @GetMapping("/health")
    public Map<String, Object> health() {
        return Map.of("status", "UP", "timestamp", Instant.now().toString());
    }

    @GetMapping("/info")
    public Map<String, String> info() {
        return Map.of("application", "devops-demo-api", "purpose", "Jenkins DevSecOps portfolio demo");
    }

    @GetMapping("/version")
    public Map<String, String> version() {
        return Map.of("version", version);
    }

    @GetMapping("/simulate-error")
    public void simulateError() {
        throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Intentional error for observability testing");
    }
}

