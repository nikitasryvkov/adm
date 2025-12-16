# ===========================================
# Этап 1: Build — собираем JAR внутри Docker
# ===========================================
FROM maven:3.9.6-eclipse-temurin-21 AS builder
WORKDIR /app

# Кэшируем зависимости
COPY pom.xml .
RUN mvn -B -q -DskipTests dependency:go-offline

# Копируем исходники
COPY src src

# Сборка (зависимости на контракты подтянутся из Maven)
RUN mvn -B -DskipTests package

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
RUN chown -R javauser:javauser /app

USER javauser

# WebSocket порт
EXPOSE 8083

ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"

HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
    CMD wget -q --spider http://localhost:8083/actuator/health || exit 1

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
