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
cd $(dirname ${0})

if [ -z ${1} ]; then
    bucket="s3://ixortalktooling-prd-aws-cloudformation"
    extra_opts="--acl public-read"
else
    bucket=${1}
    extra_opts=
fi

echo "Refreshing bucket ${bucket}"

aws s3 rm ${bucket} --recursive

aws s3 cp ../stacks/cloudfront.yaml ${bucket} ${extra_opts}
aws s3 cp ../stacks/vpc.yaml ${bucket} ${extra_opts}
aws s3 cp ../stacks/rds-auth.yaml ${bucket} ${extra_opts}
aws s3 cp ../stacks/ecs-infra.yaml ${bucket} ${extra_opts}
aws s3 cp ../stacks/core-services.yaml ${bucket}/ ${extra_opts}
aws s3 cp ../stacks/iot-services.yaml ${bucket}/ ${extra_opts}

aws s3 cp ../templates/infrastructure/ ${bucket}/infrastructure/ --recursive ${extra_opts}

aws s3 cp ../templates/services/ ${bucket}/services/ --recursive ${extra_opts}
