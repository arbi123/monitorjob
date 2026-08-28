package com.monitor;

import com.monitor.config.MonitorConfig;
import io.github.bonigarcia.wdm.WebDriverManager;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.MethodSource;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;

import java.time.Duration;
import java.util.List;
import java.util.stream.Stream;

import static org.junit.jupiter.api.Assertions.fail;

class KeywordMonitorTest {

    private static MonitorConfig config;
    private WebDriver driver;

    @BeforeAll
    static void loadConfig() {
        config = MonitorConfig.load();
        WebDriverManager.chromedriver().setup();
    }

    static Stream<String> monitorUrls() {
        return MonitorConfig.load().getUrls().stream();
    }

    @ParameterizedTest(name = "Monitor URL: {0}")
    @MethodSource("monitorUrls")
    void pageShouldNotContainForbiddenKeywords(String url) {
        driver = createDriver();
        try {
            driver.get(url);
            String html = driver.getPageSource().toLowerCase();

            List<String> found = config.getKeywords().stream()
                    .filter(keyword -> html.contains(keyword.toLowerCase()))
                    .toList();

            if (!found.isEmpty()) {
                fail("Forbidden keywords found on " + url + ": " + found);
            }
        } finally {
            quitDriver();
        }
    }

    private WebDriver createDriver() {
        ChromeOptions options = new ChromeOptions();
        if (config.isHeadless()) {
            options.addArguments("--headless=new");
        }
        options.addArguments("--no-sandbox", "--disable-dev-shm-usage", "--disable-gpu");

        WebDriver webDriver = new ChromeDriver(options);
        webDriver.manage().timeouts().pageLoadTimeout(Duration.ofSeconds(config.getTimeoutSeconds()));
        return webDriver;
    }

    @AfterEach
    void tearDown() {
        quitDriver();
    }

    private void quitDriver() {
        if (driver != null) {
            driver.quit();
            driver = null;
        }
    }
}
