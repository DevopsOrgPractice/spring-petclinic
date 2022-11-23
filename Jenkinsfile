pipeline {
    agent {label 'NODE1'}
        options {
        timeout(time: 1, unit: 'HOURS')
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
    environment {
        
    }
    stages {
        stage('Code cloning from SCM') {
            steps {
                git url: "${params.SCM_URL}",
                branch: "${params.BRANCH_TO_BUILD}"
            }
        }
        stage('Build the code with sonar scans') {
            steps {
                withSonarQubeEnv('SONAR_LATEST') {
                    sh script: "${params.MAVEN_GOAL}"
                }
            }
        }
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

        // stage() {
        //     steps {
        //         rtUpload (
        //             serverId: 'Artifactory-1',
        //             spec: '''{
        //                 "files": [
        //                     {
        //                     "pattern": "bazinga/*froggy*.zip",
        //                     "target": "bazinga-repo/froggy-files/"
        //                     }
        //                 ]
        //             }''',
        //             buildName: "${JOB_NAME }",
        //             buildNumber: "${BUILD_NUMBER }",
        //         )
        //     }
        // }

        stage('Archiving Test Reports') {
            steps {
                junit testResults: '**/surefire-reports/*.xml'
            }
        }
        stage('download artifactories & Run application') {
            agent {label 'APPSERVER'}
                options {
                timeout(time: 1, unit: 'HOURS')
            }
            steps {
                rtDownload (
                    serverId: 'JFROG_NEW',
                    spec: '''{
                        "files": [
                            {
                            "pattern": "springpet-clinic-libs-release/org/springframework/samples/spring-petclinic/2.7.3/*.jar",
                            "target": "/home/appserver/remote_root/"
                            }
                        ]
                    }''',
                )
                sh "chmod +x /home/appserver/remote_root/org/springframework/samples/spring-petclinic/2.7.3/spring-petclinic-2.7.3.jar"
                sh "java -jar /home/appserver/remote_root/org/springframework/samples/spring-petclinic/2.7.3/spring-petclinic-2.7.3.jar &"
            }
        }
    }
}