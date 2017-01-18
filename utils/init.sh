#!/bin/bash
SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $SCRIPTPATH
ENV=$(basename $SCRIPTPATH)
bucket=$(grep -A1 s3_backend global.tf |grep default|awk '{split($NF,a,"=");print a[1]}'|tr -d '"')

echo "Setting Terraform environment for $ENV" 

if [ -z "$ENV" ];then
  echo "No valid environment: $ENV"
  exit 1
fi

terraform get
terraform remote config -backend=s3 \
                        -backend-config="bucket=${bucket}" \
                        -backend-config="key=${ENV}.tfstate" \
                        -backend-config="region=eu-west-1"

echo "set remote s3 state to ${ENV}.tfstate"
