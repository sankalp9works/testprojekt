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

        	docker run --rm \
          	  -v /var/run/docker.sock:/var/run/docker.sock \
          	  aquasec/trivy image \
                  --severity HIGH,CRITICAL \
          	  --format table \
                  --output trivy-image-report.txt \
                  $IMAGE_NAME:latest || true

                  echo "Scan completed"
                  ls -l trivy-image-report.txt || true
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
            archiveArtifacts artifacts: 'trivy-image-report.txt', fingerprint: true
            echo "Pipeline completed"
        }
        success {
            echo "Deployment successful "
        }
        failure {
            echo "Pipeline failed "
        }
    }
}

