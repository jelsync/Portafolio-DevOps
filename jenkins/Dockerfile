FROM jenkins/jenkins:lts-jdk17

USER root
RUN apt-get update \
    && apt-get install --yes --no-install-recommends ca-certificates curl git jq docker.io \
    && rm -rf /var/lib/apt/lists/*

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

USER jenkins
