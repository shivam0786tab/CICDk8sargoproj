pipeline {
    agent any

    stages {

        stage('Checkout App Source Code') {
            steps {
                git credentialsId: 'git-cred-id', 
                    url: 'https://github.com/shivam0786tab/CICDk8sargoproj',
                    branch: 'main'
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-cred-id', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                }
            }
        }
		
		stage('Determine Image Tag') {
            steps {
                script {
                    def latestTag = sh(
                        script: "curl -s https://hub.docker.com/v2/repositories/shiv0786/web-app/tags?page_size=1 | jq -r '.results[0].name'",
                        returnStdout: true
                    ).trim()

                    def nextTag
					try {
						nextTag = latestTag.toInteger() + 1
					} catch (e) {
						nextTag = 1
					}
					env.IMAGE_TAG = "${nextTag}"

                    echo "🔖 Using image tag: ${env.IMAGE_TAG}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh """
                    echo 'Building Docker Image...'
                    docker build -t shiv0786/web-app:${env.IMAGE_TAG} .
                    """
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    sh """
                    echo 'Pushing Docker Image to Docker Hub...'
                    docker push shiv0786/web-app:${env.IMAGE_TAG}
                    """
                }
            }
        }

        stage('Checkout K8s Manifest Repo') {
            steps {
                git credentialsId: 'git-cred-id', 
                    url: 'https://github.com/shivam0786tab/kubernetesmanifests',
                    branch: 'main'
            }
        }

        stage('Update K8s Manifest and Push') {
            steps {
                script {
                     withCredentials([usernamePassword(credentialsId: 'git-cred-id', usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_PASSWORD')]) {
                sh """
                echo "Updating K8s deployment YAML..."
                cat node-app.yml

                # Replace image tag in a more generic way
                sed -i "s|image: shiv0786/web-app:.*|image: shiv0786/web-app:${env.IMAGE_TAG}|g" node-app.yml

                cat node-app.yml

                # Git config
                git config user.name "$GIT_USERNAME"
                git config user.email "test@email.com"

                # Set remote using credentials securely
                git remote set-url origin https://$GIT_USERNAME:$GIT_PASSWORD@github.com/shivam0786tab/kubernetesmanifests

                # Commit and push
                git add node-app.yml
                git commit -m "Updated image tag to ${env.IMAGE_TAG} | Jenkins Pipeline" || echo "No changes to commit"
                git push origin main
                """
            }
        }
    }
}
    }
}