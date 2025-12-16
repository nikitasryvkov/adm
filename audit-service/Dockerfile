# ===========================================
# Этап 1: Build — собираем JAR внутри Docker
# Собираем сначала events-contract, затем audit-service
# ===========================================
FROM maven:3.9.6-eclipse-temurin-21 AS builder
WORKDIR /workspace

# Копируем весь проект (контракты и сервисы)
COPY . .

# Сначала собираем контракт, затем сервис
RUN mvn -B -DskipTests -f events-contract/pom.xml clean install && \
    mvn -B -DskipTests -f audit-service/pom.xml clean package

# ===========================================
# Этап 2: Runtime
# ===========================================
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Создаем пользователя для безопасности
RUN addgroup -S javauser && adduser -S javauser -G javauser

# Копируем артефакт из build-слоя
COPY --from=builder /workspace/audit-service/target/*.jar /app/app.jar

# Меняем владельца
RUN chown javauser:javauser /app/app.jar

USER javauser

# HTTP порт
EXPOSE 8082

ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"

HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
    CMD wget -q --spider http://localhost:8082/actuator/health || exit 1

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
