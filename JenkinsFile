pipeline {
    agent any

    environment {
        DOCKER_USER = 'kiteysa999'
        DOCKER_PASS = credentials('docker-hub-pat')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $DOCKER_USER/projekt360:latest .'
            }
        }

        stage('Security Scan') {
            steps {
                sh 'docker run --rm -v $PWD:/app aquasec/trivy fs --severity HIGH,CRITICAL /app || true'
            }
        }

        stage('Docker Login & Push') {
            steps {
                sh '''
                    echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                    docker push $DOCKER_USER/projekt360:latest
                '''
            }
        }
    }

    triggers {
        pollSCM('H/1 * * * *') // Poll GitHub every 1 minute
    }

    post {
        always { echo "Pipeline finished" }
    }
}

