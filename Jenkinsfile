pipeline {
    agent {label 'NODE1'}
        options {
        timeout(time: 1, unit: 'HOURS')
    }
    triggers {
        pollSCM '* * * * *'
    }
    stages {
        stage('Code cloning from SCM') {
         steps {
            git url: 'https://github.com/hariprasad291/spring-petclinic.git',
            branch: 'main'
           }
        }
        stage('Build with sonarqube-analysis') {
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
                    goals: 'install',
                    // Maven options.
                    deployerId: 'spc-deployer'
                )
            }
        }
    }
}