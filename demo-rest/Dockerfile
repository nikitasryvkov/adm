# ===========================================
# Этап 1: Сборка артефакта (из готового target/*.jar)
# Здесь мы просто берем уже собранный JAR, чтобы не тянуть инструменты в финальный образ.
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

# Создаем пользователя для безопасности (не запускаем от root)
RUN addgroup -S javauser && adduser -S javauser -G javauser

# Копируем артефакт из build-слоя
COPY --from=builder /app/app.jar /app/app.jar

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
