package io.github.jelsync.devopsdemo.api;

import static org.hamcrest.Matchers.containsString;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest(properties = "app.version=test-version")
@AutoConfigureMockMvc
class DemoControllerTest {
    @Autowired private MockMvc mockMvc;

    @Test void healthReturnsUp() throws Exception {
        mockMvc.perform(get("/api/health")).andExpect(status().isOk()).andExpect(jsonPath("$.status").value("UP"));
    }

    @Test void infoContainsOnlyPublicMetadata() throws Exception {
        mockMvc.perform(get("/api/info")).andExpect(status().isOk())
            .andExpect(jsonPath("$.application").value("devops-demo-api"));
    }

    @Test void versionUsesConfiguredValue() throws Exception {
        mockMvc.perform(get("/api/version")).andExpect(status().isOk())
            .andExpect(content().string(containsString("test-version")));
    }

    @Test void simulatedErrorReturns500WithoutMessageLeak() throws Exception {
        mockMvc.perform(get("/api/simulate-error")).andExpect(status().isInternalServerError());
    }
}

