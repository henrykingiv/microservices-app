pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = 'docker-creds'
        DOCKER_IMAGE = 'henrykingiv/checkoutservice'
    }

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
                        def majorVersion = '1'
                        def buildNumber = env.BUILD_NUMBER.toInteger()
                        def formattedBuildNumber = String.format('%02d', buildNumber)
                        def imageTag = "${majorVersion}.${formattedBuildNumber}"
                        sh "docker build -t ${DOCKER_IMAGE}:${imageTag} ."
                    }
                }
            }
        }

        stage('Push') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker-creds', toolName: 'docker') {
                        def majorVersion = '1'
                        def buildNumber = env.BUILD_NUMBER.toInteger()
                        def formattedBuildNumber = String.format('%02d', buildNumber)
                        def imageTag = "${majorVersion}.${formattedBuildNumber}"
                        sh "docker push ${DOCKER_IMAGE}:${imageTag}"
                    }
                }
            }
        }
        stage('Checkout Main Branch') {
            steps {
                checkout([
                    $class: 'GitSCM', branches: [[name:'main']], userRemoteConfigs: [[url: 'https://github.com/henrykingiv/microservices-app.git']]
                ])
            }
        }

        stage('Update Manifest File') {
            steps {
                script {
                    // Update the manifest file with the new image tag
                    def manifestFile = 'home/deployment-service.yaml' "HEAD:main"
                    sh """
                    sed -i 's|image: ${DOCKER_IMAGE}:.*|image: ${DOCKER_IMAGE}:${env.IMAGE_TAG}|' ${manifestFile} 
                    """

                    // Configure git user
                    sh 'git config user.name "jenkins"'
                    sh 'git config user.email "jenkins@example.com"'

                    // Commit the changes
                    sh "git add ${manifestFile}"
                    sh 'git commit -m "Update image tag to ${DOCKER_IMAGE}:${env.IMAGE_TAG}"'

                    // Push the changes
                    withCredentials([usernamePassword(credentialsId: 'git-creds', usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_PASSWORD')]) {
                        sh "git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/henrykingiv/microservices-app.git HEAD:main"
                    }
                }
            }
        }
        
        stage('Clean up disk') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker-creds', toolName: 'docker') {
                        def majorVersion = '1'
                        def buildNumber = env.BUILD_NUMBER.toInteger()
                        def formattedBuildNumber = String.format('%02d', buildNumber)
                        def imageTag = "${majorVersion}.${formattedBuildNumber}"
                        sh "docker rmi ${DOCKER_IMAGE}:${imageTag}"
                    }
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
    }
}
