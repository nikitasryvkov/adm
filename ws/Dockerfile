# ===========================================
# Этап: Запуск (Runtime Stage)
# Требуется предварительная сборка JAR локально
# ===========================================
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Создаем пользователя для безопасности
RUN addgroup -S javauser && adduser -S javauser -G javauser

# Копируем собранный JAR
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} app.jar

# Меняем владельца
RUN chown -R javauser:javauser /app

USER javauser

# WebSocket порт
EXPOSE 8083

ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"

HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
    CMD wget -q --spider http://localhost:8083/actuator/health || exit 1

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
