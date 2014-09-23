#!/bin/bash

test_and_source ~/Google\ Drive/Stanford/aws/aws_secrets

export AWS_CREDENTIAL_FILE=~/Google\ Drive/Stanford/aws/aws-credentials-sef.txt

export AWS_ACCESS_KEY=$AWS_ACCESS_KEY_ID
export AWS_SECRET_KEY=$AWS_SECRET_ACCESS_KEY

export EC2_URL=https://ec2.us-west-1.amazonaws.com
export AWS_DEFAULT_REGION=us-west-1
export EC2_REGION=$AWS_DEFAULT_REGION

# Each amazon tool is different. Each to be installed in it's own dir
# (usually under /usr/local) and each added to path. Each also expects
# it's own "HOME" variable to be set.

function awst {
    local tool_variable_name=$1
    local tool_location_start=$2
    local executible_subdir=$3

    # if not specified, subdir to use is /bin
    if [ "x$executible_subdir" == "x" ]; then
        executible_subdir=bin
    fi

    local tool_dir=`/bin/ls -1d ${tool_location_start}* 2>/dev/null | tail -1`
    if [ x$tool_dir != "x" ]; then
        export $tool_variable_name=$tool_dir
        export PATH=$PATH:$tool_dir/$executible_subdir
    fi
}


#    HOME VARIABLE            LOCATION                             SUBDIR
#    ------------------------ ------------------------------------ --------------------
awst EC2_HOME                 /usr/local/ec2-api-tools
awst AWS_ELB_HOME             /usr/local/ElasticLoadBalancing
awst AWS_EB_HOME              /usr/local/AWS-ElasticBeanstalk-CLI  eb/macosx/python2.7
awst AWS_CLOUDFORMATION_HOME  /usr/local/AWSCloudFormation
awst AWS_RDS_HOME             /usr/local/RDSCli
awst AWS_ELASTICACHE_HOME     /usr/local/AmazonElastiCacheCli
awst AWS_AUTO_SCALING_HOME    /usr/local/AutoScaling

unset -f awst   # don't need anymore
