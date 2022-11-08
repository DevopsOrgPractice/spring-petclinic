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
    }
    stages {
        stage('Code cloning from SCM') {
            steps {
                git url: 'https://github.com/hariprasad291/spring-petclinic.git',
                branch: "${params.BRANCH_TO_BUILD}"
            }
        }
        stage('Run sonar scans') {
            steps {
                withSonarQubeEnv('SONAR_LATEST') {
                    sh script: "mvn package sonar:sonar"
                }
            }
        }
        stage('Artifactory-Configuration') {
            steps {
                rtMavenDeployer (
                    id: 'spc-deployer',
                    serverId: 'JFROG_PETCLINIC',
                    releaseRepo: 'springpet-clinic-libs-release',
                    snapshotRepo: 'springpet-clinic-libs-snapshot'
                    
                )
            }
        }
        stage('Build the Code and Deploy') {
            steps {
                rtMavenRun (
                    // Tool name from Jenkins configuration.
                    tool: 'MVN_BUILD',
                    pom: 'pom.xml',
                    goals: 'package',
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
            agent {label 'APPSERVER'}
                options {
                timeout(time: 1, unit: 'HOURS')
            }
            steps {
                rtDownload (
                    serverId: 'JFROG_PETCLINIC',
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
                sh "java -jar /home/appserver/remote_root/org/springframework/samples/spring-petclinic/2.7.3/spring-petclinic-2.7.3.jar"
            }
        }
    }
}