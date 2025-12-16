FROM jenkins/jenkins:lts-jdk21

USER root

# Устанавливаем плагины, указанные в plugins.txt
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

USER jenkins


