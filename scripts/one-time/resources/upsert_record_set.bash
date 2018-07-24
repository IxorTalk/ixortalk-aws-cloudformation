#! /bin/bash
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

usage() {
  cat << EOF
${0} recordname recordtype recordvalue

Example:
  ${0} host001.acme.com A \$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4/)

  The above command will add a A record to the hostedzone example.com, the value of the record
  is the ipv4 address of the ec2 instance

EOF
}

install_prereqs() {
  sudo yum install -y jq
}

name_to_hostedzone() {
  name=${1}
  name=${name%.}  ### Remove trailing dot
  name=${name#*.} ### Remove first part of name to obtain domain
  name="${name}." ### Add trailing dot because that's how the domain is in Route53

  aws route53 list-hosted-zones | jq -r ".[] | map(select(.Name==\"${name}\")) | .[] .Id"
}

create_batch_file() {
  name=${1}
  rectype=${2}
  val=${3}
cat > /tmp/batch.json << EOF
{
  "Comment": "Create or update a Record Set in a hosted zone",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "${name}",
        "Type": "${rectype}",
        "TTL": 300,
        "ResourceRecords": [
          {
            "Value": "${val}"
          }
        ]
      }
    }
  ]
}
EOF
}

if [[ $# -ne 3 ]]
then
  usage
  exit 1
fi

install_prereqs
create_batch_file ${@}
aws route53 change-resource-record-sets \
        --hosted-zone-id $(name_to_hostedzone ${1}) \
        --change-batch file:///tmp/batch.json
