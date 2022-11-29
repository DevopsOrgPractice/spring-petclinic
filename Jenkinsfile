pipeline {
    agent {label 'APPSERVER'}
        options {
        timeout(time: 1, unit: 'HOURS')
    }
    environment{
        DOCKER_TAG = "${env.BUILD_ID}"
        DOCKER_IMAGE = "springpetclinic"
    }
    triggers {
        pollSCM '* * * * *'
    }
    parameters {
        choice(name: 'BRANCH_TO_BUILD', choices: ['hari-Jenkins', 'main'], description: 'Branch to build')
        string(name: 'SCM_URL', defaultValue: 'https://github.com/hariprasad291/spring-petclinic.git', description: 'SCM URL for source code')
        string(name: 'MAVEN_GOAL', defaultValue: "mvn package sonar:sonar", description: 'Maven goal for building')
        string(name: 'RELEASE_REPO', defaultValue: "spring-new-libs-release", description: 'Repo for releses')
        string(name: 'SNAPSHOT_REPO', defaultValue: "spring-new-libs-snapshot", description: 'Repo for snapshot releses')
        
    }
    stages {
        stage('Code cloning from SCM') {
            agent { label('KUBERNETES')  }
                options {
                timeout(time: 1, unit: 'HOURS')
            }
            steps {
                git url: "${params.SCM_URL}",
                branch: "${params.BRANCH_TO_BUILD}"
            }
        }
        // stage('Build the code with sonar scans') {
        //     steps {
        //         withSonarQubeEnv('SONAR_LATEST') {
        //             sh script: "${params.MAVEN_GOAL}"
        //         }
        //     }
        // }
        // stage("Quality Gate") {
        //     steps {
        //       timeout(time: 1, unit: 'HOURS') {
        //         waitForQualityGate abortPipeline: true
        //       }
        //     }
        // }
        stage('Artifactory-Configuration') {
            steps {
                rtMavenDeployer (
                    id: 'spc-deployer',
                    serverId: 'JFROG_NEW',
                    releaseRepo: "${params.RELEASE_REPO}",
                    snapshotRepo: "${params.SNAPSHOT_REPO}"
                    
                )
            }
        }
        stage('Build the Code and Deploy') {
            steps {
                rtMavenRun (
                    // Tool name from Jenkins configuration.
                    tool: 'MVN_BUILD',
                    pom: 'pom.xml',
                    goals: 'install',
                    // Maven options.
                    deployerId: 'spc-deployer'
                )
            }
        }

        stage('Archiving Test Reports') {
            steps {
                junit testResults: '**/surefire-reports/*.xml'
            }
        }
        stage('download artifactories & Run application') {
            agent {label 'KUBERNETES'}
                options {
                timeout(time: 1, unit: 'HOURS')
            }
            steps {
                rtDownload (
                    serverId: 'JFROG_NEW',
                    spec: '''{
                        "files": [
                            {
                            "pattern": "spring-new-libs-release/org/springframework/samples/spring-petclinic/2.7.3/*.jar",
                            "target": "./"
                            }
                        ]
                    }''',
                )
                sh '''
                    chmod +x org/springframework/samples/spring-petclinic/2.7.3/spring-petclinic-2.7.3.jar
                    cp org/springframework/samples/spring-petclinic/2.7.3/spring-petclinic-2.7.3.jar . 
                '''
                script{
                    // withCredentials([string(credentialsId: 'JFROG_NEW', variable: 'Password')]) {
                             sh '''
                                docker build -t harispringpetclinicnew.jfrog.io/spring-new-docker/${DOCKER_IMAGE}:${DOCKER_TAG} .
                                docker login -u ${env.JFROG_USERNAME} -p ${env.JFROG_TOKEN} harispringpetclinicnew.jfrog.io  
                                docker push  harispringpetclinicnew.jfrog.io/spring-new-docker/${DOCKER_IMAGE}:${DOCKER_TAG}
                                // docker rmi harispringpetclinicnew.jfrog.io/spring-new-docker/${DOCKER_IMAGE}:${DOCKER_TAG} 
                            '''
                }
            }
        }
        stage('Deploy on appserver using ansible') {
            agent {label 'APPSERVER'}
                options {
                timeout(time: 1, unit: 'HOURS')
            }
            steps {
                dir("${env.WORKSPACE}/spring-latest") {
                    sh script: "ansible-playbook -i Inventory playbook.yml"
                }
            }
        }
    }
}