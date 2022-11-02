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
        stage('Artifactory-Configuration') {
            steps {
                rtMavenDeployer (
                    id: 'spc-deployer',
                    serverId: 'JFROG_PETCLINIC',
                    releaseRepo: 'springpet-clinic-libs-release',
                    snapshotRepo: 'springpet-clinic-libs-snapshot',
                    
                )
            }
        }
        stage(Build the Code and sonarqube-analysis) {
            steps {
                withSonarQubeEnv(SONAR_LATEST) {
                //     sh script: &quot;mvn ${params.GOAL} sonar:sonar&quot;}

                    rtMavenRun (
                        // Tool name from Jenkins configuration.
                        tool: MVN_BUILD,
                        pom: pom.xml,
                        goals: install,
                        // Maven options.
                        deployerId: spc-deployer,
                    )
                }
            }
        }
    }
}