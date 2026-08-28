# Web Keyword Monitor

Selenium Java monitor that checks web pages for forbidden keywords. If any keyword is found in the page source, the test **fails** and Jenkins sends a Discord alert. If no keywords are found, the test **passes** silently.

## How it works

| Result | Meaning | Notification |
|--------|---------|--------------|
| **PASS** | No forbidden keywords on the page | None |
| **FAIL** | One or more forbidden keywords found | Discord webhook |

This is intentionally inverted from typical "assert text exists" tests — you are monitoring for **bad** content (errors, downtime messages, etc.).

## Project structure

```
monitorjob/
├── pom.xml
├── Jenkinsfile
├── src/test/resources/monitor.properties
└── src/test/java/com/monitor/
    ├── KeywordMonitorTest.java
    └── config/MonitorConfig.java
```

## Prerequisites (local)

- Java 25+
- Maven 3.8+
- Google Chrome (WebDriverManager downloads ChromeDriver automatically)

## Configuration

Edit [`src/test/resources/monitor.properties`](src/test/resources/monitor.properties):

```properties
monitor.urls=https://example.com,https://other-site.com/health
monitor.keywords=error,down,maintenance,500 Internal Server Error
browser.headless=true
browser.timeout.seconds=30
```

Or override via environment variables:

| Variable | Overrides |
|----------|-----------|
| `MONITOR_URLS` | Comma-separated URL list |
| `MONITOR_KEYWORDS` | Comma-separated keyword list |

## Run locally

```bash
mvn clean test
```

Windows override example:

```cmd
set MONITOR_URLS=https://example.com
set MONITOR_KEYWORDS=error,down
mvn test
```

Linux/macOS override example:

```bash
export MONITOR_URLS=https://example.com
export MONITOR_KEYWORDS=error,down
mvn test
```

## Jenkins setup — Freestyle job (recommended)

### 1. Install prerequisites on the Jenkins server

1. **JDK 25** — Manage Jenkins → Tools → JDK installations → add JDK named `jdk25`
2. **Maven** — Manage Jenkins → Tools → Maven → add Maven named `maven3`
3. **Google Chrome** + **curl** — install on the Jenkins agent (Linux example):

   ```bash
   wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
   sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
   sudo apt update && sudo apt install -y google-chrome-stable curl
   ```

### 2. Store Discord webhook as a Jenkins credential

1. In Discord: Server Settings → Integrations → Webhooks → copy your webhook URL
2. Jenkins → **Manage Jenkins** → **Credentials** → **(global)** → **Add Credentials**
   - Kind: **Secret text**
   - ID: `discord-webhook-url`
   - Secret: paste your Discord webhook URL (do **not** commit this to GitHub)

### 3. Create the Freestyle job

1. Jenkins dashboard → **New Item**
2. Name: `kosova-ticket-monitor` → select **Freestyle project** → **OK**

### 4. Configure Source Code Management

1. Select **Git**
2. Repository URL: `https://github.com/arbi123/monitorjob.git`
3. Branch: `*/main`

### 5. Configure Build Triggers (every 3 minutes)

1. Check **Build periodically**
2. Schedule: `H/3 * * * *`

   This runs roughly every 3 minutes (Jenkins staggers builds with `H` to avoid load spikes).

### 6. Configure Build Environment

1. Check **Use secret text(s) or file(s)** (Credentials Binding plugin — install if missing)
2. Click **Add** → **Secret text**
   - Variable: `DISCORD_WEBHOOK_URL`
   - Credentials: select `discord-webhook-url`

### 7. Configure Build Steps

1. Click **Add build step** → **Execute shell**
2. Paste:

   ```bash
   export MONITOR_URLS='https://eu.ebileta.al/biglietteria/listaEventiPub.do'
   export MONITOR_KEYWORDS='KOSOVE - IRELAND,KOSOVE - IRANDË,KOSOVE - IRLANDË,KOSOVE - IRANDA,IRELAND,IRLANDË,IRLANDA,Irealnd,ireland,Ireland,Irlandë,irlandë,Irlanda,irlanda,Nations league,nations league,NATIONS LEAGUE,Liga e Kombeve,liga e kombeve,LIGA E KOMBEVE,Liga e Kombëve,liga e kombëve,LIGA E KOMBËVE'

   chmod +x scripts/jenkins-build.sh
   ./scripts/jenkins-build.sh
   ```

   Or without the script:

   ```bash
   export MONITOR_URLS='https://eu.ebileta.al/biglietteria/listaEventiPub.do'
   export MONITOR_KEYWORDS='KOSOVE - IRELAND,KOSOVE - IRANDË,KOSOVE - IRLANDË,KOSOVE - IRANDA,IRELAND,IRLANDË,IRLANDA,Irealnd,ireland,Ireland,Irlandë,irlandë,Irlanda,irlanda,Nations league,nations league,NATIONS LEAGUE,Liga e Kombeve,liga e kombeve,LIGA E KOMBEVE,Liga e Kombëve,liga e kombëve,LIGA E KOMBËVE'

   mvn -B clean test
   EXIT_CODE=$?
   if [ $EXIT_CODE -ne 0 ]; then
     curl -s -H "Content-Type: application/json" \
       -d "{\"content\":\"🚨 **${JOB_NAME}** build **#${BUILD_NUMBER}** FAILED\\nIreland / Nations League tickets detected!\\n${BUILD_URL}\"}" \
       "$DISCORD_WEBHOOK_URL"
   fi
   exit $EXIT_CODE
   ```

### 8. Save and run

1. Click **Save**
2. Click **Build Now**
3. Open **Console Output** — confirm Maven runs, Chrome starts, test completes
4. Green build = no Ireland keywords found (no Discord message)
5. Red build = keywords found → Discord alert sent

---

## Jenkins setup — Pipeline job (alternative)

### 1–2. Same prerequisites and Discord credential as above

### 3. Create the Pipeline job

1. **New Item** → name: `kosova-ticket-monitor` → **Pipeline** → OK
2. Under **Pipeline**:
   - Definition: **Pipeline script from SCM**
   - SCM: **Git**
   - Repository URL: `https://github.com/arbi123/monitorjob.git`
   - Branch: `*/main`
   - Script Path: `Jenkinsfile`
3. Save → **Build Now**

The `Jenkinsfile` already runs every 3 minutes (`H/3 * * * *`) and sends Discord on failure only.

---

## Push to GitHub

```bash
git add .
git commit -m "Add Selenium Kosovo ticket monitor with Jenkins and Discord"
git push -u origin main
```

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `chromedriver` / Chrome version mismatch | WebDriverManager should auto-resolve; ensure Chrome is installed on the agent |
| Tests hang | Increase `browser.timeout.seconds` or add pipeline `timeout` option |
| No Discord message on failure | Verify credential ID is `discord-webhook-url` and `curl` is available on the agent |
| Headless Chrome crashes on Linux | `--no-sandbox` and `--disable-dev-shm-usage` are already set in the test |
