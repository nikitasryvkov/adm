# ===========================================
# Этап 1: Build — собираем JAR внутри Docker
# Сначала собираем events-contract, затем ws (notification-service)
# ===========================================
FROM maven:3.9.6-eclipse-temurin-21 AS builder
WORKDIR /workspace

# Копируем весь проект
COPY . .

# Собираем контракт и затем WebSocket-сервис
RUN mvn -B -DskipTests -f events-contract/pom.xml clean install && \
    mvn -B -DskipTests -f ws/pom.xml clean package

# ===========================================
# Этап 2: Runtime
# ===========================================
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Создаем пользователя для безопасности
RUN addgroup -S javauser && adduser -S javauser -G javauser

# Копируем артефакт из build-слоя
COPY --from=builder /workspace/ws/target/*.jar /app/app.jar

# Меняем владельца
RUN chown -R javauser:javauser /app

USER javauser

# WebSocket порт
EXPOSE 8083

ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"

HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
    CMD wget -q --spider http://localhost:8083/actuator/health || exit 1

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
