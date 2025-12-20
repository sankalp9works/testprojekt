pipeline {
    agent any

    environment {
        DOCKER_USER = 'kiteysa999'
        DOCKER_PASS = credentials('docker-hub-pat')
        IMAGE_NAME  = 'kiteysa999/projekt360'
        CONTAINER   = 'projekt360-container'
        APP_PORT    = '80'
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                echo "Building Docker image..."
                docker build -t $IMAGE_NAME:latest .
                '''
            }
        }

        stage('Security Scan (Trivy)') {
            steps {
                sh '''
                echo "Running Trivy image scan..."

                # Run Trivy and generate table (text) report
                docker run --rm \
                  -v /var/run/docker.sock:/var/run/docker.sock \
                  -v $PWD:/workspace \
                  aquasec/trivy image \
                  --severity LOW,MEDIUM,HIGH,CRITICAL \
                  --format table \
                  --output /workspace/trivy-image-report.txt \
                  $IMAGE_NAME:latest || true

                # Generate HTML report using Trivy template
                docker run --rm \
                  -v /var/run/docker.sock:/var/run/docker.sock \
                  -v $PWD:/workspace \
                  aquasec/trivy image \
                  --severity LOW,MEDIUM,HIGH,CRITICAL \
                  --format template \
                  --template "@contrib/html.tpl" \
                  --output /workspace/trivy-image-report.html \
                  $IMAGE_NAME:latest || true

                echo "Trivy scan completed. Reports generated:"
                ls -l trivy-image-report.*
                '''
            }
        }

        stage('Docker Login & Push') {
            steps {
                sh '''
                echo "Logging into Docker Hub..."
                echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin

                echo "Pushing image to Docker Hub..."
                docker push $IMAGE_NAME:latest
                '''
            }
        }

        stage('Deploy Container') {
            steps {
                sh '''
                echo "Deploying container..."
                docker rm -f $CONTAINER || true
                docker run -d \
                  --name $CONTAINER \
                  -p $APP_PORT:80 \
                  $IMAGE_NAME:latest
                '''
            }
        }
    }

    triggers {
        pollSCM('* * * * *')
    }

    post {
        always {
            archiveArtifacts artifacts: 'trivy-image-report.txt,trivy-image-report.html',
                             allowEmptyArchive: true,
                             fingerprint: true
            echo "Pipeline completed with artifacts archived"
        }
        success {
            echo "Deployment successful"
        }
        failure {
            echo "Pipeline failed"
        }
    }
}

