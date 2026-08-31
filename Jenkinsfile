pipeline {
    agent any

    options {
        timeout(time: 10, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '30'))
    }

    environment {
        DISCORD_WEBHOOK_URL = credentials('discord-webhook-url')
        SLACK_WEBHOOK_URL = credentials('slack-webhook-url')
        MONITOR_URLS = 'https://eu.ebileta.al/biglietteria/listaEventiPub.do'
        MONITOR_KEYWORDS = 'KOSOVE - IRELAND,KOSOVE - IRANDË,KOSOVE - IRLANDË,KOSOVE - IRANDA,IRELAND,IRLANDË,IRLANDA,Irealnd,ireland,Ireland,Irlandë,irlandë,Irlanda,irlanda,Nations league,nations league,NATIONS LEAGUE,Liga e Kombeve,liga e kombeve,LIGA E KOMBEVE,Liga e Kombëve,liga e kombëve,LIGA E KOMBËVE'
    }

    triggers {
        cron('H/3 * * * *')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Run Monitor') {
            tools {
                jdk 'jdk25'
                maven 'maven3'
            }
            steps {
                sh 'mvn -B clean test'
            }
        }
    }

    post {
        failure {
            sh '''
                MESSAGE="🚨 **${JOB_NAME}** build **#${BUILD_NUMBER}** FAILED\\nIreland / Nations League tickets detected!\\n${BUILD_URL}"
                scripts/send-alert.sh "$MESSAGE"
            '''
        }
    }
}
