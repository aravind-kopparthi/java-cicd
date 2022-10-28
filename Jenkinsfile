def changeList = ""
def revision = "2.3.2"
def sha1 = ""
pipeline {
    agent {
        dockerfile {
            filename 'Dockerfile.java8agent'
        }
    }

   environment {
       
       result = "0.0.0"
       
    }
    options {
        buildDiscarder logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '1', daysToKeepStr: '', numToKeepStr: '10')
        disableConcurrentBuilds()
    }
    stages {
        stage('Prepare') {
           when {
                 not { branch 'main' }
              }
            steps {
                script{
                    changeList = "-SNAPSHOT"
                    sha1 = env.GIT_COMMIT.take(7)
                }
            }
             
        }
        stage('Build') {
            steps {
                sh "mvn verify -Drevision=${revision} -Dchangelist=${changeList} -Dsha1=${sha1}"
            }
        }
        stage('NextTag') {
            when {
                branch 'main'
            }
            steps {
              script {
                  try {  
                  version = sh (script: 'git describe --tags $(git rev-list --tags --max-count=1)',returnStdout: true).trim()
                  }
                   catch (Exception e) {
                      echo 'Exception occurred: ' + e.toString()
                       version = "v0.0.1"
                  }
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
                        //sh 'git push git@github.com/aravind-kopparthi/java-cicd.git $(cat TAG_NAME.txt)'
                        sh 'git push https://github.com/aravind-kopparthi/java-cicd.git $(cat TAG_NAME.txt)'
                        
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
