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
        stage("build with sonar scan") {
            steps {
                sh "mvn package sonar:sonar"
            }
        }
        stage('Archiving and Test Results') {
            steps {
                junit testResults: 'target/surefire-reports/*.xml'
            }
        }
    }
}
    //     stage('publish the artifacts to J Frog artifactory')  {
    //         steps {
                
    //         }
    //    }
    // }
    // agent {label 'NODE2'}
    //     options {
    //     timeout(time: 1, unit: 'HOURS')
    // stages {
    //     sage
    // }
