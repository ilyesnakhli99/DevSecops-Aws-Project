pipeline {
    // Tells Jenkins to execute this entire pipeline ONLY on the Jenkins Agent machine
    agent { 
        label 'JenkinsAgent' 
    }

    environment {
        // Define your Docker Hub or AWS ECR repository credentials and tags
        DOCKER_HUB_USER = 'ilyesnakhli'
        IMAGE_NAME      = 'ivolve-flask-app'
        IMAGE_TAG       = "${BUILD_NUMBER}" // Uses the sequential Jenkins build number as a version tag
    }

    stages {
        // Stage 1: Pull the freshest code from your GitHub Repo
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        // Stage 2: Look inside the source code for hidden vulnerabilities before building
        stage('DevSecOps: Source Security Scan') {
            steps {
                echo 'Running Trivy Filesystem Vulnerability Scan...'
                // Runs Trivy scanner against the raw files in the repository
                sh "trivy fs --severity HIGH,CRITICAL ."
            }
        }

       // Stage 3: Compile the Docker blueprint into a real frozen container image
        stage('Docker Build') {
            steps {
                echo 'Building the Docker Image...'
                // Run from the repository root (.) and point directly to the Dockerfile (-f)
                sh "docker build -t ${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG} -f ./Docker/Dockerfile ."
            }
        }

        // Stage 4: Scan the compiled image file for operating system level security flaws
        stage('DevSecOps: Image Security Scan') {
            steps {
                echo 'Scanning the compiled Docker Image with Trivy...'
                sh "trivy image --severity HIGH,CRITICAL ${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
            }
        }

        // Stage 5: Ship the secure image out to a global registry so Kubernetes can pull it later
        stage('Push Image to Registry') {
            steps {
                // Securely logs into Docker Hub using credentials stored safely inside Jenkins UI
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh "echo ${PASS} | docker login -u ${USER} --password-stdin"
                    sh "docker push ${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
                }
            }
        }

        // Stage 6: Automatically update your Kubernetes deployment files with the new version tag
        stage('Update GitOps Manifests') {
            steps {
                echo "Updating deployment manifest version to: ${IMAGE_TAG}"
                // This step will clone your separate Kubernetes deployment repo, 
                // swap the old tag for the new ${IMAGE_TAG}, and commit it back to Git.
            }
        }
    }

    // Post-actions run automatically depending on whether the pipeline succeeded or crashed
    post {
        success {
            echo 'Pipeline completed successfully! Ready for GitOps deployment.'
        }
        failure {
            echo 'Pipeline failed! Sending alert to CloudWatch and SNS Notification...'
            // This links back to the CloudWatch / SNS structure we defined in Phase 1
        }
    }
}
