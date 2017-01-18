import org.jenkinsci.plugins.workflow.steps.FlowInterruptedException

def terraform_version = "terraform-0.7.3"
print "terraform_version = ${terraform_version}"
def envs = ["dev","staging"]

def create_builders(terraform_command, envs) {
  builders = [:]
  for (x in envs) {
      def label = x
      builders["${stage_name}-${label}"] = {
        terraformRun(terraform_command,label)
      }
  }
  return builders
}

def terraformRun(command,environment) {
  withEnv([
      "PATH=${terraform}:${env.PATH}"
  ])
  {
      withCredentials([
          [$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'terraform', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']
      ]) {
          wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'XTerm']) {
                return_code = sh returnStdout: false, script: """#!/bin/bash +e
                  cd $environment
                  ./init.sh
                  terraform $command
               """
          }
      }
  }
}

def builder_node = "master"
branch = env.BRANCH_NAME
def terraform_command = "plan"
def merge = []

if (branch != "master" ) {
  //builder_node = "build-dev"
  merge = [[$class: 'WipeWorkspace']] + [[
      $class: 'PreBuildMerge',
      options: [
          fastForwardMode: 'NO_FF',
          mergeRemote: 'origin',
          mergeStrategy: 'MergeCommand.Strategy',
          mergeTarget: 'master'
      ]
  ]]
} else { // master
  terraform_command = "apply"
}
print "branch=$branch"
print "terraform_command=$terraform_command"
print "node=$builder_node"

node(builder_node) {

    stage 'Checkout'
    checkout([
        $class: 'GitSCM',
        branches: scm.branches,
        userRemoteConfigs: scm.userRemoteConfigs,
        submoduleCfg: [],
        doGenerateSubmoduleConfigurations: scm.doGenerateSubmoduleConfigurations,
        extensions: scm.extensions + merge
    ])

    terraform = tool name: terraform_version, type: 'com.cloudbees.jenkins.plugins.customtools.CustomTool'
    print "terraform=$terraform"

    stage_name = terraform_command
    stage "env-$stage_name"
        builders = create_builders(terraform_command, envs)
        parallel builders
}
