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
            git url: 'https://github.com/Prasadsgithub/spring-petclinic.git',
            branch: 'main'
           }
        }
        stage("build") {
            steps {
                sh "mvn package"
            }
        }
    stage('reporting test reports') {
            steps {
                junit testResults: '**/surefire-reports/*.xml'
            }
       }
    }
}