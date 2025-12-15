pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'localhost:5000'
        APP_VERSION = "${env.BUILD_NUMBER}"
    }
    
    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 30, unit: 'MINUTES')
        disableConcurrentBuilds()
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Получение исходного кода...'
                checkout scm
            }
        }
        
        stage('Build Contracts') {
            steps {
                echo 'Сборка контрактов...'
                retry(3) {
                    dir('events-contract') {
                        sh 'chmod +x ./mvnw && ./mvnw clean install -DskipTests'
                    }
                }
                retry(3) {
                    dir('books-api-contract') {
                        sh 'chmod +x ./mvnw && ./mvnw clean install -DskipTests'
                    }
                }
            }
        }
        
        stage('Build Services') {
            parallel {
                stage('Build Demo REST') {
                    steps {
                        echo 'Сборка Demo REST...'
                        dir('demo-rest') {
                            sh 'chmod +x ./mvnw && ./mvnw clean package -DskipTests'
                        }
                    }
                }
                stage('Build Analytics Service') {
                    steps {
                        echo 'Сборка Analytics Service...'
                        dir('analytics-service') {
                            sh 'chmod +x ./mvnw && ./mvnw clean package -DskipTests'
                        }
                    }
                }
                stage('Build Audit Service') {
                    steps {
                        echo 'Сборка Audit Service...'
                        dir('audit-service') {
                            sh 'chmod +x ./mvnw && ./mvnw clean package -DskipTests'
                        }
                    }
                }
                stage('Build Notification Service') {
                    steps {
                        echo 'Сборка Notification Service (WS)...'
                        dir('ws') {
                            sh 'chmod +x ./mvnw && ./mvnw clean package -DskipTests'
                        }
                    }
                }
            }
        }
        
        stage('Run Tests') {
            parallel {
                stage('Test Demo REST') {
                    steps {
                        dir('demo-rest') {
                            sh 'chmod +x ./mvnw && ./mvnw test'
                        }
                    }
                }
                stage('Test Audit Service') {
                    steps {
                        dir('audit-service') {
                            sh 'chmod +x ./mvnw && ./mvnw test'
                        }
                    }
                }
            }
        }
        
        // Docker-этапы временно отключены
        // stage('Build Docker Images') {
        //     steps {
        //         echo 'Сборка Docker образов...'
        //         script {
        //             // Установить docker-compose если его нет
        //             sh '''
        //                 if ! command -v docker-compose &> /dev/null; then
        //                     echo "Установка docker-compose..."
        //                     curl -SL https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-linux-x86_64 -o /tmp/docker-compose
        //                     chmod +x /tmp/docker-compose
        //                     sudo mv /tmp/docker-compose /usr/local/bin/docker-compose || mv /tmp/docker-compose /usr/local/bin/docker-compose
        //                 fi
        //                 docker-compose --version
        //             '''
        //             sh 'docker-compose build'
        //         }
        //     }
        // }
        
        // stage('Deploy to Docker') {
        //     steps {
        //         echo 'Развертывание в Docker...'
        //         script {
        //             // Убедиться что docker-compose установлен
        //             sh '''
        //                 if ! command -v docker-compose &> /dev/null; then
        //                     curl -SL https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-linux-x86_64 -o /tmp/docker-compose
        //                     chmod +x /tmp/docker-compose
        //                     sudo mv /tmp/docker-compose /usr/local/bin/docker-compose || mv /tmp/docker-compose /usr/local/bin/docker-compose
        //                 fi
        //             '''
        //             // Остановить и удалить все контейнеры из compose
        //             sh 'docker-compose down --remove-orphans -v || true'
        //             
        //             // Удалить ВСЕ конфликтующие контейнеры (включая запущенные в Docker Desktop)
        //             sh '''
        //                 # Найти docker
        //                 DOCKER=$(command -v docker || echo "docker")
        //                 
        //                 # Список контейнеров для удаления
        //                 CONTAINERS="zipkin prometheus rabbitmq grafana demo-rest audit-service analytics-service notification-service"
        //                 
        //                 # Удалить все контейнеры по имени (включая остановленные)
        //                 for name in $CONTAINERS; do
        //                     echo "Удаление контейнера: $name"
        //                     # Остановить и удалить по имени
        //                     $DOCKER stop "$name" 2>/dev/null || true
        //                     $DOCKER rm -f "$name" 2>/dev/null || true
        //                     
        //                     # Найти и удалить по ID (включая с префиксами проекта)
        //                     $DOCKER ps -aq --filter "name=${name}" 2>/dev/null | while read id; do
        //                         if [ -n "$id" ]; then
        //                             echo "Остановка контейнера по ID: $id"
        //                             $DOCKER stop "$id" 2>/dev/null || true
        //                             $DOCKER rm -f "$id" 2>/dev/null || true
        //                         fi
        //                     done
        //                 done
        //                 
        //                 # Дополнительно: найти и удалить все контейнеры с нужными именами
        //                 $DOCKER ps -a --format "{{.ID}} {{.Names}}" 2>/dev/null | grep -iE "(zipkin|prometheus|rabbitmq|grafana|demo-rest|audit-service|analytics-service|notification-service)" | awk '{print $1}' | while read id; do
        //                     if [ -n "$id" ]; then
        //                         echo "Удаление контейнера по ID из списка: $id"
        //                         $DOCKER stop "$id" 2>/dev/null || true
        //                         $DOCKER rm -f "$id" 2>/dev/null || true
        //                     fi
        //                 done
        //                 
        //                 # Принудительно удалить известный проблемный контейнер zipkin по полному ID
        //                 echo "Принудительное удаление контейнера zipkin по ID..."
        //                 $DOCKER rm -f b63058766b7ef85dbc2b6986aea554d9fdbb09712a6f1d7cdf9940a56abb560d 2>/dev/null || true
        //                 # Или по короткому ID
        //                 $DOCKER rm -f b63058766b7e 2>/dev/null || true
        //                 
        //                 echo "Проверка оставшихся контейнеров:"
        //                 $DOCKER ps -a --format "{{.Names}}" | grep -iE "(zipkin|prometheus|rabbitmq|grafana|demo-rest|audit-service|analytics-service|notification-service)" || echo "Конфликтующих контейнеров не найдено"
        //             '''
        //             
        //             // Запустить с пересозданием (без jenkins - он уже работает отдельно)
        //             sh 'docker-compose up -d --force-recreate --scale jenkins=0'
        //         }
        //     }
        // }
        
        // stage('Health Check') {
        //     steps {
        //         echo 'Проверка состояния сервисов...'
        //         sleep(time: 30, unit: 'SECONDS')
        //         sh 'curl -f http://localhost:8080/actuator/health || exit 1'
        //     }
        // }
    }
    
    post {
        always {
            echo 'Pipeline завершен'
            deleteDir()
        }
        success {
            echo 'Сборка успешно завершена!'
        }
        failure {
            echo 'Сборка завершилась с ошибкой!'
        }
    }
}
