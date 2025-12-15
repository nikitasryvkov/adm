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
                dir('events-contract') {
                    bat 'mvnw.cmd clean install -DskipTests'
                }
                dir('books-api-contract') {
                    bat 'mvnw.cmd clean install -DskipTests'
                }
            }
        }
        
        stage('Build Services') {
            parallel {
                stage('Build Demo REST') {
                    steps {
                        echo 'Сборка Demo REST...'
                        dir('demo-rest') {
                            bat 'mvnw.cmd clean package -DskipTests'
                        }
                    }
                }
                stage('Build Analytics Service') {
                    steps {
                        echo 'Сборка Analytics Service...'
                        dir('analytics-service') {
                            bat 'mvnw.cmd clean package -DskipTests'
                        }
                    }
                }
                stage('Build Audit Service') {
                    steps {
                        echo 'Сборка Audit Service...'
                        dir('audit-service') {
                            bat 'mvnw.cmd clean package -DskipTests'
                        }
                    }
                }
                stage('Build Notification Service') {
                    steps {
                        echo 'Сборка Notification Service (WS)...'
                        dir('ws') {
                            bat 'mvnw.cmd clean package -DskipTests'
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
                            bat 'mvnw.cmd test'
                        }
                    }
                    post {
                        always {
                            junit allowEmptyResults: true, testResults: 'demo-rest/target/surefire-reports/*.xml'
                        }
                    }
                }
                stage('Test Audit Service') {
                    steps {
                        dir('audit-service') {
                            bat 'mvnw.cmd test'
                        }
                    }
                    post {
                        always {
                            junit allowEmptyResults: true, testResults: 'audit-service/target/surefire-reports/*.xml'
                        }
                    }
                }
            }
        }
        
        stage('Build Docker Images') {
            steps {
                echo 'Сборка Docker образов...'
                script {
                    bat 'docker-compose build'
                }
            }
        }
        
        stage('Deploy to Docker') {
            steps {
                echo 'Развертывание в Docker...'
                script {
                    bat 'docker-compose down --remove-orphans || exit 0'
                    bat 'docker-compose up -d'
                }
            }
        }
        
        stage('Health Check') {
            steps {
                echo 'Проверка состояния сервисов...'
                script {
                    sleep(time: 30, unit: 'SECONDS')
                    
                    // Проверка Demo REST
                    bat '''
                        curl -f http://localhost:8080/actuator/health || exit 1
                    '''
                    
                    // Проверка Prometheus
                    bat '''
                        curl -f http://localhost:9090/-/healthy || exit 1
                    '''
                    
                    // Проверка Grafana
                    bat '''
                        curl -f http://localhost:3000/api/health || exit 1
                    '''
                }
            }
        }
    }
    
    post {
        always {
            echo 'Pipeline завершен'
            cleanWs()
        }
        success {
            echo 'Сборка успешно завершена!'
        }
        failure {
            echo 'Сборка завершилась с ошибкой!'
        }
    }
}

