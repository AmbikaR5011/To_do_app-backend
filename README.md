# To-do App — Quick Start

Quick checklist
- [ ] Install JDK 21 and set `JAVA_HOME`.
- [ ] Install MySQL (or run via Docker).
- [ ] Create the `to_do_app` database and user (commands below).
- [ ] Configure `src/main/resources/application.properties` if needed.
- [ ] Build and run with the Maven wrapper: `.\mvnw.cmd clean package` then `java -jar ...`.
- [ ] Run tests: `.\mvnw.cmd test`.

Project files
- Main class: `src/main/java/com/example/to_do_app/ToDoAppApplication.java`
- App config: `src/main/resources/application.properties`
- Build: `mvnw`, `mvnw.cmd`, `pom.xml`

Prerequisites
1. JDK 21 installed and `JAVA_HOME` pointing to it.
   - Verify:
   ```powershell
   java -version
   $env:JAVA_HOME
   ```
2. Maven wrapper is included (`mvnw`, `mvnw.cmd`) — you'll use `.\mvnw.cmd` on PowerShell.
3. MySQL server (local or remote). MySQL client (optional) for creation steps.

1) Create MySQL database and user
- Option A — interactive (recommended; prompts for root password):
```powershell
mysql -u root -p
# then inside MySQL client, run:
CREATE DATABASE `to_do_app`;
CREATE USER 'todo_user'@'%' IDENTIFIED BY 'todo_pass';
GRANT ALL PRIVILEGES ON `to_do_app`.* TO 'todo_user'@'%';
FLUSH PRIVILEGES;
EXIT;
```

- Option B — single-line (convenient, exposes password on command-line):
```powershell
mysql -u root -p"root123" -e "CREATE DATABASE `to_do_app`; CREATE USER 'todo_user'@'%' IDENTIFIED BY 'todo_pass'; GRANT ALL PRIVILEGES ON `to_do_app`.* TO 'todo_user'@'%'; FLUSH PRIVILEGES;"
```

- Notes:
  - Replace `root123`, `todo_user`, and `todo_pass` with your secure values.
  - If MySQL runs in Docker, you can also supply `MYSQL_DATABASE`, `MYSQL_USER`, `MYSQL_PASSWORD` environment variables when starting the container.

2) How to configure `src/main/resources/application.properties`
- Current file contains (explained below):
```properties
spring.application.name=to-do-app

# ---------------- DATABASE ----------------
spring.datasource.url=jdbc:mysql://localhost:3306/to_do_app
spring.datasource.username=root
spring.datasource.password=root123
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver

# ---------------- JPA ----------------
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.database-platform=org.hibernate.dialect.MySQLDialect

# ---------------- SERVER ----------------
server.port=8080
```

- Explanations and edits:
  - `spring.datasource.url` — JDBC URL. Change `localhost:3306` to point to your MySQL host, port, or use a container host. To connect to a remote DB: `jdbc:mysql://db.example.com:3306/to_do_app`.
  - `spring.datasource.username` / `spring.datasource.password` — DB credentials. Replace with `todo_user`/`todo_pass` if you created that user.
  - `spring.datasource.driver-class-name` — MySQL JDBC driver class (no change normally).
  - `spring.jpa.hibernate.ddl-auto` — controls schema generation:
    - `update` (current) updates schema automatically (convenient for dev).
    - Use `validate` or remove in prod, or use migrations (Flyway/Liquibase) for production.
  - `spring.jpa.show-sql=true` — prints SQL to logs (useful in dev).
  - `spring.jpa.database-platform` — Hibernate dialect for MySQL.
  - `server.port` — change to run on a different port.

- Profiles / environment-specific config:
  - Create `src/main/resources/application-dev.properties` or `application-prod.properties` with overrides.
  - Activate a profile at runtime:
    ```powershell
    # Pass as JVM arg
    java -jar .\target\to-do-app-0.0.1-SNAPSHOT.jar --spring.profiles.active=dev

    # Or set environment variable for a single PowerShell session
    $env:SPRING_PROFILES_ACTIVE="dev"; java -jar .\target\to-do-app-0.0.1-SNAPSHOT.jar
    ```
  - Or run via Maven:
    ```powershell
    .\mvnw.cmd -Dspring-boot.run.profiles=dev spring-boot:run
    ```

3) Build and run (Windows PowerShell)
- Package (produce runnable Spring Boot jar):
```powershell
.\mvnw.cmd clean package
```
- Run the jar (artifact name from `pom.xml` is `to-do-app-0.0.1-SNAPSHOT.jar`):
```powershell
java -jar .\target\to-do-app-0.0.1-SNAPSHOT.jar
```
- Run with specific profile or override properties on the command-line:
```powershell
java -jar .\target\to-do-app-0.0.1-SNAPSHOT.jar --spring.datasource.username=todo_user --spring.datasource.password=todo_pass
```
- Run from IDE:
  - Import the project as a Maven project (IntelliJ IDEA: Open `pom.xml`).
  - Run the main class: `com.example.to_do_app.ToDoAppApplication` (right-click → Run).
  - Use Run Configurations to add VM/Program arguments (profiles, env vars).

4) Run tests
- Run full test suite:
```powershell
.\mvnw.cmd test
```
- Run package with tests:
```powershell
.\mvnw.cmd clean package
```
- Skip tests (not recommended for CI):
```powershell
.\mvnw.cmd clean package -DskipTests
```

5) Start the app with Docker (optional)
- Minimal Dockerfile (single-stage, using the packaged jar):
```dockerfile
# Dockerfile
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY target/to-do-app-0.0.1-SNAPSHOT.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","/app/app.jar"]
```
- Build and run locally:
```powershell
docker build -t to-do-app:latest .
docker run -p 8080:8080 --env SPRING_DATASOURCE_URL="jdbc:mysql://host.docker.internal:3306/to_do_app" --env SPRING_DATASOURCE_USERNAME=todo_user --env SPRING_DATASOURCE_PASSWORD=todo_pass to-do-app:latest
```
- Run MySQL in Docker and network together:
```powershell
docker network create todo-net
docker run -d --name todo-mysql --network todo-net -e MYSQL_ROOT_PASSWORD=root123 -e MYSQL_DATABASE=to_do_app -e MYSQL_USER=todo_user -e MYSQL_PASSWORD=todo_pass -p 3306:3306 mysql:8.0

# Build app image and run on same network
docker build -t to-do-app:latest .
docker run -d --name todo-app --network todo-net -p 8080:8080 to-do-app:latest
```
- Notes:
  - If the app is inside Docker and the MySQL container is on the same Docker network, use the MySQL container name as host in `spring.datasource.url`, e.g. `jdbc:mysql://todo-mysql:3306/to_do_app`.

6) Troubleshooting tips (common errors)
- Java version mismatch / “UnsupportedClassVersionError”
  - Symptom: app fails to start; error mentions major.minor version.
  - Fix:
    ```powershell
    java -version
    # Install JDK 21 if needed and set JAVA_HOME
    $env:JAVA_HOME = 'C:\\Program Files\\Java\\jdk-21'
    ```
- DB connection refused / “Communications link failure”
  - Symptom: cannot connect to MySQL.
  - Checks:
    ```powershell
    # Confirm MySQL listening on 3306 locally
    netstat -an | Select-String "3306"
    # Or try connecting with mysql client
    mysql -u todo_user -p -h 127.0.0.1 -P 3306
    ```
  - Fixes:
    - Ensure MySQL service is running.
    - If MySQL is remote, ensure host and port are reachable and firewall rules allow it.
    - For Docker, use correct host: `host.docker.internal` (Windows) or Docker network service name.
- Missing JDBC driver / ClassNotFoundException: com.mysql.cj.jdbc.Driver
  - Symptom: runtime error about missing driver.
  - Fix:
    - `pom.xml` already includes `mysql-connector-j` (runtime scope). If you see issues, re-run:
    ```powershell
    .\mvnw.cmd clean package
    ```
    - Ensure you run the fat jar created by Spring Boot Maven Plugin (it bundles runtime dependencies).
- Schema mismatch / JPA errors
  - Symptom: SQL errors at startup.
  - Fix:
    - Check `spring.jpa.hibernate.ddl-auto` (set to `update` in dev).
    - Consider using migrations (Flyway or Liquibase) for production.
- Inspect logs
  - Run jar and watch console logs:
  ```powershell
  java -jar .\target\to-do-app-0.0.1-SNAPSHOT.jar
  ```
  - If you redirect logs:
  ```powershell
  java -jar .\target\to-do-app-0.0.1-SNAPSHOT.jar > app.log 2>&1; Get-Content .\app.log -Wait
  ```

Other notes
- The `pom.xml` uses `java.version=21` and includes `spring-boot-starter-data-jpa` and `mysql-connector-j`. No immediate dependency changes are needed for a dev setup.
- For production, do not keep plaintext credentials in `application.properties`. Use environment variables, external config, or a secrets manager:
```powershell
# Example: run with env vars in PowerShell for one session
$env:SPRING_DATASOURCE_USERNAME="todo_user"; $env:SPRING_DATASOURCE_PASSWORD="todo_pass"; java -jar .\target\to-do-app-0.0.1-SNAPSHOT.jar
```

If you want, I can:
- Add a minimal `docker-compose.yml` for local dev (MySQL + app).
- Add a sample `application-dev.properties` and a short script to bootstrap the DB.
- Or directly create the `README.md` file in the repo (I have done that).

Please tell me if you want the Docker compose or sample dev properties added.

