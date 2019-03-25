# IxorTalk AWS CloudFormation

This module contains AWS CloudFormation templates (and some convenience scripts) to deploy an IxorTalk instance to AWS.

For general documentation about the IxorTalk platform: https://github.com/ixortalk/ixortalk-gateway

## Prerequisites

What you'll need:

Required:
* An AWS Account with admin privileges (admin privileges are required because of the creation of IAM related resources)
* A `projectName` and `env` to be used: Two variables that will be used across the templates to create dynamic resource names and environment configuration
* A public hosted zone for the domain you want to deploy the IxorTalk instance to
* Two *separate* certificates:
    * To be used for the loadbalancers with name `*.yourdomain.com` and additional name `*.internal.yourdomain.com`
    * To be used for CloudFront with name `*.yourdomain.com` in region `us-east-1`
* A MongoDB instance to be used by Asset Mgmt (https://github.com/IxorTalk/ixortalk-assetmgmt)
* Two S3 buckets for (see [Deploying](#deploying))
    * static assets: to be used by CloudFront
    * ECS hosts: containing files that will be required when starting en ECS hosts (eg. docker auth config file) 
* A config repo containing the IxorTalk platform configuration (eg. https://github.com/ixortalk/ixortalk.config.demo).  When starting from a fork of [ixortalk.config.demo](https://github.com/ixortalk/ixortalk.config.demo), minimal changes to made will be:
    * `application.yml`: `ixortalk.loadbalancer.internal.host`: replace by your own domain
    * `application.yml`: `ixortalk.loadbalancer.external.host`: replace by your own domain
    * `ixortalk.assetmgmt/application.yml`: `spring.data.mongodb.uri`: replace with the URI to your MongoDB instance

Optional:
* An AWS Key Pair to be used to ssh into the bastion host and EC2 Host (to be specified as a paramter when deploying EC2 hosts)
* AWS IoT Root Certificates to use JIT device registration

## Deploying

### One-off operations 

#### Static content S3 Bucket

Create an S3 bucket containing static assets to be used by CloudFront, example script:

```
./scripts/one-time/create-static-content-s3-bucket.sh $PROJECT_NAME $ENV <folder_containing_static_resources_to_upload>
```

Which assets need to be present depends on the ixortalk-gateway configuration.  By default a `background.jpg` and `logo.png` will be required.  

See https://github.com/IxorTalk/ixortalk.config.demo/blob/aws/ixortalk.gateway/application.yml for an example configuration on how logo and background get resolved.  The logo is retrieved via `/assets/instance/logo.png` which will be mapped to `${ixortalk.assets.base-url}` which will typically map to the CloudFront domain (eg. https://assets.demo-ixortalk.com).

#### ECS Host files

Create an S3 bucket containing files required when launching ECS instances, currently it only expects an optional `ecs-auth.config` file containing auth info for Docker.  See [ecs-cluster.yaml](templates/infrastructure/ecs-cluster.yaml) for more details.

```
./scripts/one-time/create-ecs-s3-bucket.sh $PROJECT_NAME $ENV <folder_containing_files_to_upload>
```    

### Deploying templates 

Deploy the following templates (in order) to your AWS account either via AWS CLI or manually via the console:

| Template | |
| -- | -- | 
|[cloudfront.yaml](stacks/cloudfront.yaml)|[![cloudformation-launch-button](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?#/stacks/new?stackName=cloudfront&templateURL=https://s3.eu-central-1.amazonaws.com/ixortalktooling-prd-aws-cloudformation/cloudfront.yaml)|
|[vpc.yaml](stacks/vpc.yaml)|[![cloudformation-launch-button](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?#/stacks/new?stackName=vpc&templateURL=https://s3.eu-central-1.amazonaws.com/ixortalktooling-prd-aws-cloudformation/vpc.yaml)|
|[rds-auth.yaml](stacks/rds-auth.yaml)|[![cloudformation-launch-button](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?#/stacks/new?stackName=rds-auth&templateURL=https://s3.eu-central-1.amazonaws.com/ixortalktooling-prd-aws-cloudformation/rds-auth.yaml)|
|[ecs-infra.yaml](stacks/ecs-infra.yaml)|[![cloudformation-launch-button](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?#/stacks/new?stackName=ecs-infra&templateURL=https://s3.eu-central-1.amazonaws.com/ixortalktooling-prd-aws-cloudformation/ecs-infra.yaml)|
|[core-services.yaml](stacks/core-services.yaml)|[![cloudformation-launch-button](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?#/stacks/new?stackName=core-services&templateURL=https://s3.eu-central-1.amazonaws.com/ixortalktooling-prd-aws-cloudformation/core-services.yaml)|
|[iot-services.yaml](stacks/iot-services.yaml)|[![cloudformation-launch-button](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?#/stacks/new?stackName=iot-services&templateURL=https://s3.eu-central-1.amazonaws.com/ixortalktooling-prd-aws-cloudformation/iot-services.yaml)|

## Contributing

Pull requests are welcome.

## License

```
MIT License

Copyright (c) 2018 IxorTalk CVBA

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

```
