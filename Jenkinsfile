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
                script {
                    // Установить docker-compose если его нет
                    sh '''
                        if ! command -v docker-compose &> /dev/null; then
                            echo "Установка docker-compose..."
                            curl -SL https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-linux-x86_64 -o /tmp/docker-compose
                            chmod +x /tmp/docker-compose
                            sudo mv /tmp/docker-compose /usr/local/bin/docker-compose || mv /tmp/docker-compose /usr/local/bin/docker-compose
                        fi
                        docker-compose --version
                    '''
                    sh 'docker-compose build'
                }
            }
        }
        
        stage('Deploy to Docker') {
            steps {
                echo 'Развертывание в Docker...'
                script {
                    // Убедиться что docker-compose установлен
                    sh '''
                        if ! command -v docker-compose &> /dev/null; then
                            curl -SL https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-linux-x86_64 -o /tmp/docker-compose
                            chmod +x /tmp/docker-compose
                            sudo mv /tmp/docker-compose /usr/local/bin/docker-compose || mv /tmp/docker-compose /usr/local/bin/docker-compose
                        fi
                    '''
                    // Остановить и удалить все контейнеры из compose
                    sh 'docker-compose down --remove-orphans -v || true'
                    
                    // Удалить ВСЕ конфликтующие контейнеры (включая остановленные)
                    sh '''
                        # Найти docker (может быть в разных местах)
                        for docker_cmd in docker /usr/local/bin/docker /usr/bin/docker; do
                            if command -v "$docker_cmd" &> /dev/null || [ -x "$docker_cmd" ]; then
                                DOCKER="$docker_cmd"
                                break
                            fi
                        done
                        
                        if [ -z "$DOCKER" ]; then
                            echo "Docker не найден, пропускаем удаление контейнеров"
                        else
                            # Удалить все контейнеры с нужными именами
                            for name in zipkin prometheus rabbitmq grafana demo-rest audit-service analytics-service notification-service; do
                                # Удалить по имени
                                $DOCKER rm -f "$name" 2>/dev/null || true
                                # Удалить по ID если контейнер существует
                                $DOCKER ps -aq --filter "name=^${name}$" 2>/dev/null | while read id; do
                                    [ -n "$id" ] && $DOCKER rm -f "$id" 2>/dev/null || true
                                done
                            done
                        fi
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
