package com.monitor.config;

import java.io.IOException;
import java.io.InputStream;
import java.util.Arrays;
import java.util.List;
import java.util.Properties;
import java.util.stream.Collectors;

public final class MonitorConfig {

    private static final String PROPERTIES_FILE = "monitor.properties";
    private static final String ENV_URLS = "MONITOR_URLS";
    private static final String ENV_KEYWORDS = "MONITOR_KEYWORDS";

    private final List<String> urls;
    private final List<String> keywords;
    private final boolean headless;
    private final int timeoutSeconds;

    private MonitorConfig(List<String> urls, List<String> keywords, boolean headless, int timeoutSeconds) {
        this.urls = urls;
        this.keywords = keywords;
        this.headless = headless;
        this.timeoutSeconds = timeoutSeconds;
    }

    public static MonitorConfig load() {
        Properties properties = new Properties();
        try (InputStream input = MonitorConfig.class.getClassLoader().getResourceAsStream(PROPERTIES_FILE)) {
            if (input == null) {
                throw new IllegalStateException("Could not find " + PROPERTIES_FILE + " on the classpath");
            }
            properties.load(input);
        } catch (IOException e) {
            throw new IllegalStateException("Failed to load " + PROPERTIES_FILE, e);
        }

        String urlsValue = envOrProperty(ENV_URLS, properties.getProperty("monitor.urls", ""));
        String keywordsValue = envOrProperty(ENV_KEYWORDS, properties.getProperty("monitor.keywords", ""));
        boolean headless = Boolean.parseBoolean(properties.getProperty("browser.headless", "true"));
        int timeoutSeconds = Integer.parseInt(properties.getProperty("browser.timeout.seconds", "30"));

        List<String> urls = parseCommaSeparated(urlsValue);
        List<String> keywords = parseCommaSeparated(keywordsValue);

        if (urls.isEmpty()) {
            throw new IllegalStateException("No monitor URLs configured. Set monitor.urls or MONITOR_URLS.");
        }
        if (keywords.isEmpty()) {
            throw new IllegalStateException("No monitor keywords configured. Set monitor.keywords or MONITOR_KEYWORDS.");
        }

        return new MonitorConfig(urls, keywords, headless, timeoutSeconds);
    }

    private static String envOrProperty(String envName, String propertyValue) {
        String envValue = System.getenv(envName);
        if (envValue != null && !envValue.isBlank()) {
            return envValue;
        }
        return propertyValue;
    }

    private static List<String> parseCommaSeparated(String value) {
        if (value == null || value.isBlank()) {
            return List.of();
        }
        return Arrays.stream(value.split(","))
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .collect(Collectors.toList());
    }

    public List<String> getUrls() {
        return urls;
    }

    public List<String> getKeywords() {
        return keywords;
    }

    public boolean isHeadless() {
        return headless;
    }

    public int getTimeoutSeconds() {
        return timeoutSeconds;
    }
}
