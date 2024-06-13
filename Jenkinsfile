pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Build & Tag Docker Image') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker-creds', toolName: 'docker') {
                        sh "docker build -t henrykingiv/frontend:latest ."
                    }
                }
            }
        }
        
        stage('Push Docker Image') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker-creds', toolName: 'docker') {
                        sh "docker push henrykingiv/frontend:latest"
                    }
                }
            }
        }
    }
}
