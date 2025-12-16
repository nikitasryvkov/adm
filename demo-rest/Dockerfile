# ===========================================
# Этап 1: Build — собираем JAR внутри Docker
# Сначала собираем контракты, затем demo-rest
# ===========================================
FROM maven:3.9.6-eclipse-temurin-21 AS builder
WORKDIR /workspace

# Копируем весь проект
COPY . .

# Собираем events-contract и books-api-contract, затем demo-rest
RUN mvn -B -DskipTests -f events-contract/pom.xml clean install && \
    mvn -B -DskipTests -f books-api-contract/pom.xml clean install && \
    mvn -B -DskipTests -f demo-rest/pom.xml clean package

# ===========================================
# Этап 2: Runtime
# ===========================================
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Создаем пользователя для безопасности (не запускаем от root)
RUN addgroup -S javauser && adduser -S javauser -G javauser

# Копируем артефакт из build-слоя
COPY --from=builder /workspace/demo-rest/target/*.jar /app/app.jar

# Меняем владельца файла
RUN chown javauser:javauser /app/app.jar

# Переключаемся на непривилегированного пользователя
USER javauser

# Документируем порт
EXPOSE 8080

# Настройки JVM для контейнера
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
    CMD wget -q --spider http://localhost:8080/actuator/health || exit 1

# Запускаем приложение
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
