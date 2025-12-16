# ===========================================
# Этап 1: Build — собираем JAR внутри Docker
# Сначала собираем контракты, затем analytics-service
# ===========================================
FROM maven:3.9.6-eclipse-temurin-21 AS builder
WORKDIR /workspace

# Копируем весь проект (контракты + сервисы)
COPY . .

# Собираем events-contract и books-api-contract, затем analytics-service
RUN mvn -B -DskipTests -f events-contract/pom.xml clean install && \
    mvn -B -DskipTests -f books-api-contract/pom.xml clean install && \
    mvn -B -DskipTests -f analytics-service/pom.xml clean package

# ===========================================
# Этап 2: Runtime
# ===========================================
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Создаем пользователя для безопасности
RUN addgroup -S javauser && adduser -S javauser -G javauser

# Копируем артефакт из build-слоя
COPY --from=builder /workspace/analytics-service/target/*.jar /app/app.jar

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
