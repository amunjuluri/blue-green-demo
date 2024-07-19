pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = "anandmunjuluri/bgapp"
        KUBERNETES_NAMESPACE = "bluegreen"
        KUBERNETES_DEPLOYMENT_NAME = "bgapp"
    }
    
    stages {
        stage('Verify Docker') {
            steps {
                sh 'docker --version'
            }
        }   
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${DOCKER_IMAGE}:${BUILD_NUMBER}")
                }
            }
        }
        
        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-credentials') {
                        docker.image("${DOCKER_IMAGE}:${BUILD_NUMBER}").push()
                    }
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    def activeColor = sh(script: "kubectl get service ${KUBERNETES_DEPLOYMENT_NAME} -n ${KUBERNETES_NAMESPACE} -o jsonpath='{.spec.selector.color}'", returnStdout: true).trim()
                    def newColor = activeColor == 'blue' ? 'green' : 'blue'
                    
                    sh "sed -i '' 's|{{COLOR}}|${newColor}|g' k8s/deployment.yaml"
                    sh "sed -i '' 's|{{VERSION}}|${BUILD_NUMBER}|g' k8s/deployment.yaml"
                    
                    sh "kubectl apply -f k8s/deployment.yaml -n ${KUBERNETES_NAMESPACE}"
                    
                    sh "kubectl rollout status deployment/${KUBERNETES_DEPLOYMENT_NAME}-${newColor} -n ${KUBERNETES_NAMESPACE}"
                    
                    sh "kubectl patch service ${KUBERNETES_DEPLOYMENT_NAME} -n ${KUBERNETES_NAMESPACE} -p '{\"spec\":{\"selector\":{\"color\":\"${newColor}\"}}}'"
                    
                    sh "kubectl delete deployment ${KUBERNETES_DEPLOYMENT_NAME}-${activeColor} -n ${KUBERNETES_NAMESPACE}"
                }
            }
        }
    }
}