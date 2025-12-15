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
        
        stage('Build Docker Images') {
            steps {
                echo 'Сборка Docker образов...'
                sh 'docker-compose build'
            }
        }
        
        stage('Deploy to Docker') {
            steps {
                echo 'Развертывание в Docker...'
                script {
                    // Остановить и удалить все контейнеры из compose
                    sh 'docker-compose down --remove-orphans -v || true'
                    
                    // Удалить ВСЕ конфликтующие контейнеры (включая остановленные)
                    sh '''
                        docker rm -f zipkin prometheus rabbitmq grafana demo-rest audit-service analytics-service notification-service 2>/dev/null || true
                        # Удалить по ID если не удалось по имени
                        docker ps -aq --filter "name=zipkin" | while read id; do docker rm -f "$id" 2>/dev/null || true; done
                        docker ps -aq --filter "name=prometheus" | while read id; do docker rm -f "$id" 2>/dev/null || true; done
                        docker ps -aq --filter "name=rabbitmq" | while read id; do docker rm -f "$id" 2>/dev/null || true; done
                        docker ps -aq --filter "name=grafana" | while read id; do docker rm -f "$id" 2>/dev/null || true; done
                    '''
                    
                    // Запустить с пересозданием (без jenkins - он уже работает отдельно)
                    sh 'docker-compose up -d --force-recreate --scale jenkins=0'
                }
            }
        }
        
        stage('Health Check') {
            steps {
                echo 'Проверка состояния сервисов...'
                sleep(time: 30, unit: 'SECONDS')
                sh 'curl -f http://localhost:8080/actuator/health || exit 1'
            }
        }
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
