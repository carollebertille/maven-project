pipeline {
    agent any
    parameters {
        string (name: 'BRANCH_NAME', defaultValue: 'dev', description: '')
        string (name: 'APP_NAME', defaultValue: 'maven-project-02', description: '')
    }

    stages {
        stage ('Checkout') {
            steps {
                dir("${WORKSPACE}/code") {
                    checkout([
                        $class: 'GitSCM',
                        branches: [[name: "*/${env.BRANCH_NAME}"]],
                        doGenerateSubmoduleConfigurations: false,
                        extensions: [[$class: 'LocalBranch']],
                        submoduleCfg: [],
                        userRemoteConfigs: [[
                            url: 'https://github.com/carollebertille/maven-project.git',
                        ]]
                    ])
                }
            }
        }
        stage('Remove Existing sonar-project.properties') {
            steps {
                dir("${WORKSPACE}/code/application/${params.APP_NAME}") {
                    script {
                        // Check if sonar-project.properties exists and remove it if found
                        if (fileExists('sonar-project.properties')) {
                            sh 'rm sonar-project.properties'
                        }
                    }
                }
            }
        }
        stage('Create sonar-project.properties') {
            steps {
                dir("${WORKSPACE}/code/application/${params.APP_NAME}") {
                    script {
                        // Define the content of sonar-project.properties
                        def sonarProjectPropertiesContent = """
                            sonar.host.url=http://54.164.161.118:9000
                            sonar.projectKey=project-sonar2
                            sonar.projectName=project-sonar2
                            sonar.projectVersion=1.0
                            sonar.sources=.
                            qualitygate.wait=true
                        """

                        // Create the sonar-project.properties file
                        writeFile file: 'sonar-project.properties', text: sonarProjectPropertiesContent
                    }
                }
            }
        }
        stage('Open sonar-project.properties') {
            steps {
                dir("${WORKSPACE}/code/application/${params.APP_NAME}") {
                    script {
                        // Use 'cat' command to display the content of sonar-project.properties
                        sh 'cat sonar-project.properties'
                    }
                }
            }
        }
        stage('Install sonar-scanner CLI') {
            steps {
                dir("${WORKSPACE}/code/application/${params.APP_NAME}") {
                    script {
                        def sonar_scanner_version="5.0.1.3006"
                        sh """
                            # https://github.com/SonarSource/sonar-scanner-cli/releases

                            sudo apt update -y
                            sudo apt install nodejs npm -y
                            sudo apt install maven
                            wget -q https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${sonar_scanner_version}-linux.zip
                            unzip sonar-scanner-cli-${sonar_scanner_version}-linux.zip
                            sudo mv sonar-scanner-${sonar_scanner_version}-linux sonar-scanner
                            sudo rm -rf  /var/opt/sonar-scanner || true
                            sudo mv sonar-scanner /var/opt/
                            sudo rm -rf /usr/local/bin/sonar-scanner || true
                            sudo ln -s /var/opt/sonar-scanner/bin/sonar-scanner /usr/local/bin/ || true
                            sonar-scanner -v
                        """
                    }
                }
            }
        }
        stage('SonarQube Analysis') {
            steps {
                dir("${WORKSPACE}/code/application/${params.APP_NAME}") {
                    script {
                        withSonarQubeEnv('SonarScanner') {
                            sh "/bin/mvn clean verify sonar:sonar -Dsonar.projectKey=test-sonar2"
                        }
                    }
                }
            }
        }
        stage('Cleaning The application') {
            steps {
                dir("${WORKSPACE}/code/application/${params.APP_NAME}") {
                    script {
                        sh "/bin/mvn clean"
                    }
                }
            }
        }
        stage('Compiling The application') {
            steps {
                dir("${WORKSPACE}/code/application/${params.APP_NAME}") {
                    script {
                        sh "/bin/mvn compile"
                    }
                }
            }
        }
        stage('Packaging The application') {
            steps {
                dir("${WORKSPACE}/code/application/${params.APP_NAME}") {
                    script {
                        sh "/bin/mvn package"
                    }
                }
            }
        }
        stage('Building The application') {
            steps {
                dir("${WORKSPACE}/code/application/${params.APP_NAME}") {
                    script {
                        sh """
                            ls -l
                            sudo docker build -t app .
                            sudo docker images
                        """
                    }
                }
            }
        }
        stage('Deploying The application') {
            steps {
                dir("${WORKSPACE}/code/application/${params.APP_NAME}") {
                    script {
                        sh """
                            sudo docker run -itd -p 8080:8080 app:latest
                            sudo docker ps
                        """
                    }
                }
            }
        }
    }
}
