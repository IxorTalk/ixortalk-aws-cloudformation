#!/bin/bash
#
# MIT License
#
# Copyright (c) 2018 IxorTalk CVBA
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <projectname> <environment> <ecs s3 content folder>"
	echo "ex: $0 demo tst ecs/"
	exit 1
fi

export PROJECT_NAME=$1
export ENV=$2
export ECS_S3_FOLDER=$3

bucket=ixortalk-${PROJECT_NAME}-ecs-${ENV}

aws s3api create-bucket --bucket ${bucket} --create-bucket-configuration LocationConstraint=eu-central-1
aws s3api wait bucket-exists --bucket ${bucket}

aws s3api put-bucket-versioning --bucket ${bucket} --versioning-configuration MFADelete=Disabled,Status=Enabled
aws s3api put-bucket-lifecycle-configuration --bucket ${bucket} --lifecycle-configuration file://../ixortalk-aws-cloudformation/scripts/one-time/resources/s3_config/expire-lifecycle.json
aws s3api put-bucket-encryption --bucket ${bucket} --server-side-encryption-configuration file://../ixortalk-aws-cloudformation/scripts/one-time/resources/s3_config/encryption-config.json

aws s3 cp ${ECS_S3_FOLDER} s3://${bucket}/ --recursive
aws s3 cp ../ixortalk-aws-cloudformation/scripts/one-time/resources/upsert_record_set.bash s3://${bucket}/
