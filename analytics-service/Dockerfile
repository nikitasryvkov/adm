# ===========================================
# Этап 1: Build (используем готовый target/*.jar)
# ===========================================
FROM eclipse-temurin:21-jre-alpine AS builder
WORKDIR /app
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} app.jar

# ===========================================
# Этап 2: Runtime
# ===========================================
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Создаем пользователя для безопасности
RUN addgroup -S javauser && adduser -S javauser -G javauser

# Копируем артефакт из build-слоя
COPY --from=builder /app/app.jar /app/app.jar

# Меняем владельца
RUN chown javauser:javauser /app/app.jar

USER javauser

# gRPC порт
EXPOSE 9090
# HTTP порт для метрик
EXPOSE 8081

ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"

HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
    CMD wget -q --spider http://localhost:8081/actuator/health || exit 1

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
