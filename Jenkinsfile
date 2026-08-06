pipeline {
    agent any
    options {
        timestamps()
        ansiColor('xterm')
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '20', artifactNumToKeepStr: '10'))
        timeout(time: 45, unit: 'MINUTES')
    }
    parameters {
        booleanParam(name: 'PUBLISH_IMAGE', defaultValue: false, description: 'Publicar imagen en GHCR')
        booleanParam(name: 'DEPLOY_LOCAL', defaultValue: true, description: 'Desplegar y probar localmente')
        booleanParam(name: 'RUN_SECURITY_SCAN', defaultValue: true, description: 'Ejecutar controles DevSecOps')
        string(name: 'IMAGE_TAG', defaultValue: '', description: 'Tag opcional; vacío genera BUILD_NUMBER-SHA')
    }
    environment {
        APP_DIR = 'app/devops-demo-api'
        LOCAL_IMAGE = 'local/devops-demo-api'
        CONTAINER_NAME = 'devops-demo-api-pipeline'
        REPORTS_DIR = 'reports'
        GHCR_IMAGE = 'ghcr.io/jelsync/devops-demo-api'
    }
    stages {
        stage('Checkout') { steps { checkout scm } }
        stage('Validate') {
            steps {
                sh '''set -eu
                  test -f Jenkinsfile && test -f docker-compose.yml && test -f "$APP_DIR/pom.xml"
                  mkdir -p reports/unit-tests reports/security reports/dependencies reports/container
                  docker version
                '''
            }
        }
        stage('Compile') { steps { dir("${APP_DIR}") { sh 'docker run --rm --volumes-from devsecops-jenkins -w "$PWD" maven:3.9.9-eclipse-temurin-17 mvn -B clean compile' } } }
        stage('Unit Tests') {
            steps { dir("${APP_DIR}") { sh 'docker run --rm --volumes-from devsecops-jenkins -w "$PWD" maven:3.9.9-eclipse-temurin-17 mvn -B test' } }
            post { always { junit allowEmptyResults: false, testResults: 'app/devops-demo-api/target/surefire-reports/*.xml' } }
        }
        stage('Package') { steps { dir("${APP_DIR}") { sh 'docker run --rm --volumes-from devsecops-jenkins -w "$PWD" maven:3.9.9-eclipse-temurin-17 mvn -B -DskipTests package' } } }
        stage('Secret Scan') {
            when { expression { params.RUN_SECURITY_SCAN } }
            steps { sh 'docker run --rm --volumes-from devsecops-jenkins -w "$PWD" zricethezav/gitleaks:v8.24.3 detect --source=. --no-banner --report-format=json --report-path=reports/security/gitleaks.json --redact' }
        }
        stage('Dependency Scan') {
            when { expression { params.RUN_SECURITY_SCAN } }
            steps { dir("${APP_DIR}") { sh '''docker run --rm --volumes-from devsecops-jenkins -w "$PWD" maven:3.9.9-eclipse-temurin-17 mvn -B -Dformats=HTML,JSON,JUNIT -DoutputDirectory=target/dependency-check -DfailBuildOnCVSS=9.0 org.owasp:dependency-check-maven:12.1.1:check
              mkdir -p ../../reports/dependencies
              cp -r target/dependency-check/. ../../reports/dependencies/
            ''' } }
        }
        stage('Static Analysis') {
            when { expression { params.RUN_SECURITY_SCAN } }
            steps { sh '''docker run --rm --volumes-from devsecops-jenkins -v trivy-cache:/root/.cache/trivy -w "$PWD" aquasec/trivy:0.61.1 config --severity HIGH,CRITICAL --exit-code 0 --format json --output reports/security/trivy-config.json .
              docker run --rm --volumes-from devsecops-jenkins -v trivy-cache:/root/.cache/trivy -w "$PWD" aquasec/trivy:0.61.1 config --severity CRITICAL --exit-code 1 .
            ''' }
        }
        stage('Docker Build') {
            steps {
                script {
                    env.GIT_SHA = sh(script: 'git rev-parse --short=12 HEAD', returnStdout: true).trim()
                    env.RESOLVED_TAG = params.IMAGE_TAG?.trim() ? params.IMAGE_TAG.trim() : "${env.BUILD_NUMBER}-${env.GIT_SHA}"
                }
                sh 'docker build --build-arg APP_VERSION="$RESOLVED_TAG" -t "$LOCAL_IMAGE:$RESOLVED_TAG" "$APP_DIR"'
            }
        }
        stage('Container Scan') {
            when { expression { params.RUN_SECURITY_SCAN } }
            steps {
                sh '''docker run --rm --volumes-from devsecops-jenkins -v /var/run/docker.sock:/var/run/docker.sock -v trivy-cache:/root/.cache/trivy -w "$PWD" aquasec/trivy:0.61.1 image --severity HIGH,CRITICAL --exit-code 0 --format json --output reports/container/trivy-image.json "$LOCAL_IMAGE:$RESOLVED_TAG"
                  docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v trivy-cache:/root/.cache/trivy aquasec/trivy:0.61.1 image --severity CRITICAL --ignore-unfixed --exit-code 1 "$LOCAL_IMAGE:$RESOLVED_TAG"'''
            }
        }
        stage('Publish Image') {
            when { expression { params.PUBLISH_IMAGE } }
            steps {
                withCredentials([usernamePassword(credentialsId: 'ghcr-credentials', usernameVariable: 'GHCR_USER', passwordVariable: 'GHCR_TOKEN')]) {
                    sh '''set +x
                      echo "$GHCR_TOKEN" | docker login ghcr.io -u "$GHCR_USER" --password-stdin
                      docker tag "$LOCAL_IMAGE:$RESOLVED_TAG" "$GHCR_IMAGE:$RESOLVED_TAG"
                      docker push "$GHCR_IMAGE:$RESOLVED_TAG"
                      docker logout ghcr.io
                    '''
                }
            }
        }
        stage('Deploy Local') {
            when { expression { params.DEPLOY_LOCAL } }
            steps { sh 'docker rm -f "$CONTAINER_NAME" 2>/dev/null || true; docker run -d --name "$CONTAINER_NAME" --network devsecops-platform -p 8080:8080 "$LOCAL_IMAGE:$RESOLVED_TAG"' }
        }
        stage('Health Check') {
            when { expression { params.DEPLOY_LOCAL } }
            steps { sh 'for i in $(seq 1 30); do curl -fsS "http://$CONTAINER_NAME:8080/actuator/health" && exit 0; sleep 2; done; docker logs "$CONTAINER_NAME"; exit 1' }
        }
        stage('Smoke Tests') {
            when { expression { params.DEPLOY_LOCAL } }
            steps { sh 'curl -fsS "http://$CONTAINER_NAME:8080/api/health"; curl -fsS "http://$CONTAINER_NAME:8080/api/info"; curl -fsS "http://$CONTAINER_NAME:8080/api/version"; test "$(curl -sS -o /dev/null -w %{http_code} "http://$CONTAINER_NAME:8080/api/simulate-error")" = 500' }
        }
        stage('Publish Reports') {
            steps { archiveArtifacts artifacts: 'reports/**/*,app/devops-demo-api/target/*.jar', allowEmptyArchive: true, fingerprint: true }
        }
    }
    post {
        always {
            archiveArtifacts artifacts: 'reports/**/*', allowEmptyArchive: true
            sh 'docker rm -f "$CONTAINER_NAME" 2>/dev/null || true'
            cleanWs(deleteDirs: true, notFailBuild: true)
        }
        success { echo "Pipeline exitoso: ${env.RESOLVED_TAG ?: 'sin imagen'}" }
        failure { echo "Pipeline falló. Revise el stage y los artefactos archivados." }
    }
}
