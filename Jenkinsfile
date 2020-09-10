pipeline {
    agent {
        docker { 
            image "ruby:2.7-alpine" 
            args "-u root:root" /* tell docker to access with root user*/
        }
    }

    options { 
        skipDefaultCheckout() 
    }

    environment { 
        SLACK_CHANNEL = "jenkins-morphosis"
        DEVELOPMENT_BRANCH = "development"
        TEST_BRANCH = "testing"
        STAGING_BRANCH = "staging"
        PRODUCTION_BRANCH = "master"
    }
	
    stages {  
        stage("Initialize") {              
            steps {
                sh "apk update && apk upgrade && apk add --no-cache bash git openssh"
                checkout scm   
                script {
                    GIT_COMMIT_MSG = """${sh(
                        returnStdout: true, 
                        script: 'git log -1 --pretty=%B').trim()
                        }"""
                    GIT_LATEST_COMMIT = """${sh(
                        label: 'Get previous commit', 
                        script: 'git rev-parse HEAD',
                        returnStdout: true)?.trim()
                        }"""
                    GIT_PREVIOUS_COMMIT = """${sh(
                        label: 'Get previous commit',
                        script: 'git rev-parse HEAD^', 
                        returnStdout: true)?.trim()
                        }"""
                    GIT_AUTHOR = """${sh(
                        returnStdout: true, 
                        script: "git --no-pager show -s --format='%an' ${GIT_LATEST_COMMIT}").trim()
                        }"""
                    JOB_NAME = "${env.JOB_NAME}".getAt(0..("${env.JOB_NAME}".indexOf('/') - 1))
                }
                slackSend color: "warning", 
                    channel: "${SLACK_CHANNEL}",
                    message: "${JOB_NAME} - ${env.BRANCH_NAME}, build #${env.BUILD_NUMBER} started." 
            }
        }

        stage("Build") {      
            when {   
                anyOf {
                    branch "${DEVELOPMENT_BRANCH}";
                    branch 'PR-*'
                }             
            }            
            steps {  
                slackSend color: "warning", 
                    channel: "${SLACK_CHANNEL}",
                    message: "${JOB_NAME} - ${env.BRANCH_NAME}, build #${env.BUILD_NUMBER} Build." 
            }                                    
        }

        stage("Test") {           
            when {   
                anyOf {
                    branch "${DEVELOPMENT_BRANCH}";
                    branch 'PR-*'
                }             
            }        
            steps {                
                slackSend color: "warning", 
                    channel: "${SLACK_CHANNEL}",
                    message: "${JOB_NAME} - ${env.BRANCH_NAME}, build #${env.BUILD_NUMBER} Testing." 
            }                                    
        }

        stage("Deploy") {           
            when { 
                branch "${DEVELOPMENT_BRANCH}"               
            }           
            steps {
                sshagent(credentials : ['saver-server-ssh']) {
                    sh 'ssh -o StrictHostKeyChecking=no ubuntu@13.251.151.14 uptime'
                    sh 'ssh ubuntu@13.251.151.14 \"cd /home/ubuntu/apps/saverserver/staging/current && git pull && bash .scripts/deploy-devlop.sh\"'
                }
                slackSend color: "warning", 
                    channel: "${SLACK_CHANNEL}",
                    message: "${JOB_NAME} - ${env.BRANCH_NAME}, build #${env.BUILD_NUMBER} Deploy." 
            }                                    
        }
    }
    
    post {
        cleanup {
            echo "Always clean up workspace"
            sh "rm -rf *" /* this command will delete main content in workspace which deleteDir() can't delete it.*/
            deleteDir() /* clean up our workspace again make sure workspace doesn't have any thing left*/
            dir("${env.WORKSPACE}@tmp") {
                deleteDir()
            }
            dir("${env.WORKSPACE}@script") {
                deleteDir()
            }
            dir("${env.WORKSPACE}@script@tmp") {
                deleteDir()
            }
        }
        success {
            script {                                
                slackSend color: "good", 
                    channel: "${SLACK_CHANNEL}",
                    attachments: [
                        [
                            title: "${JOB_NAME}, build #${env.BUILD_NUMBER}",
                            title_link: "${RUN_DISPLAY_URL}",
                            color: "good",
                            text: "Success\n${GIT_AUTHOR}",
                            "mrkdwn_in": ["fields"],
                            fields: [
                                [
                                    title: "Branch",
                                    value: "${env.BRANCH_NAME}",
                                    short: true
                                ],
                                [
                                    title: "Change",
                                    value: "<${RUN_CHANGES_DISPLAY_URL}|See change detail>",
                                    short: true
                                ],
                                [
                                    title: "Last Commit",
                                    value: "${GIT_COMMIT_MSG} - ${GIT_LATEST_COMMIT}",
                                    short: false
                                ]
                            ]
                        ]
                    ]                
            }
        }
        unstable {
            slackSend color: "warning", 
                channel: "${SLACK_CHANNEL}",
                attachments: [
                    [
                        title: "${JOB_NAME}, build #${env.BUILD_NUMBER}",
                        title_link: "${RUN_DISPLAY_URL}",
                        color: "warning",
                        text: "Unstable\n${GIT_AUTHOR}",
                        "mrkdwn_in": ["fields"],
                        fields: [
                            [
                                title: "Branch",
                                value: "${env.BRANCH_NAME}",
                                short: true
                            ],
                            [
                                title: "Change",
                                value: "<${RUN_CHANGES_DISPLAY_URL}|See change detail>",
                                short: true
                            ],
                            [
                                title: "Last Commit",
                                value: "${GIT_COMMIT_MSG} - ${GIT_LATEST_COMMIT}",
                                short: false
                            ]
                        ]
                    ]
                ]
        }
        failure {
            slackSend color: "danger", 
                channel: "${SLACK_CHANNEL}",
                attachments: [
                    [
                        title: "${JOB_NAME}, build #${env.BUILD_NUMBER}",
                        title_link: "${RUN_DISPLAY_URL}",
                        color: "danger",
                        text: "Failure\n${GIT_AUTHOR}",
                        "mrkdwn_in": ["fields"],
                        fields: [
                            [
                                title: "Branch",
                                value: "${env.BRANCH_NAME}",
                                short: true
                            ],
                            [
                                title: "Change",
                                value: "<${RUN_CHANGES_DISPLAY_URL}|See change detail>",
                                short: true
                            ],
                            [
                                title: "Last Commit",
                                value: "${GIT_COMMIT_MSG} - ${GIT_LATEST_COMMIT}",
                                short: false
                            ]
                        ]
                    ]
                ]
            
            /* save comment for future send email for failure*/
            // mail to: 'technical@morphos.is',
            // subject: "Failed Pipeline: ${currentBuild.fullDisplayName}",
            // body: "Something is wrong with ${env.BUILD_URL}"
        }
        changed {
            echo 'Things were different before...'
        }
    }
}