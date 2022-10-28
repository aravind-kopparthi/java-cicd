pipeline {
    agent {
        dockerfile {
            filename 'Dockerfile.java8agent'
        }
    }

    environment {
         String result = "0.0.0"
         String version = ""
    }
    options {
        buildDiscarder logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '1', daysToKeepStr: '', numToKeepStr: '10')
        disableConcurrentBuilds()
    }
    stages {
     
        stage('Build') {
            when {
                not { branch 'main' }
            }
            steps {
                    sh 'mvn verify'
            }
        }
        stage('NextTag') {
            when {
                 branch 'main'
            }
            steps {
              script {
                    version = sh (script: 'git describe --tags $(git rev-list --tags --max-count=1)',returnStdout: true).trim()
              }
              sh ' echo $version '
            }
        }
        stage('Release') {
            when {
                branch 'main'
            }
            steps {
                    sh 'git config --global user.email "aravind.kopparthi@gmail.com"'
                    sh 'git config --global user.name "Jenkins CI"'
                    sh 'mvn release:clean git-timestamp:setup-release release:prepare release:perform'
            
            }
            post {
                success {
                    // Publish the tag
                   // sshagent(['github-ssh']) {
                        // using the full url so that we do not care if https checkout used in Jenkins
                        sh 'git config --global user.email "aravind.kopparthi@gmail.com"'
                        sh 'git config --global user.name "Jenkins CI"'
                        sh 'git push git@github.com/aravind-kopparthi/maven-cd.git $(cat TAG_NAME.txt)'
               //     }
                    // Set the display name to the version so it is easier to see in the UI
                    script { currentBuild.displayName = readFile('VERSION.txt').trim() }

                    // (If using a repository manager with staging support) Close staging repo // pro
                    /// jfrog promotion 
                }
                failure {
                    // Remove the local tag as there is no matching remote tag
                    sh 'test -f TAG_NAME.txt && git tag -d $(cat TAG_NAME.txt) && rm -f TAG_NAME.txt || true'

                    // (If using a repository manager with staging support) Drop staging repo
                }
            }
        }
    }
}
