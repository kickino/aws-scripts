#!/bin/bash
# we really need bash for the array below :)

ECHO="/bin/echo"
CUT="/usr/bin/cut"
DATE="/bin/date"
GREP="/bin/grep"
AWS="/usr/local/bin/aws"

TMPCERTLIST="/tmp/aws_certlist"
CURRENTDATE=$("${DATE}" +%s)
AWSREGIONS=("us-east-1" "us-west-1" "us-west-2" "eu-west-1" "eu-central-1"
           "ap-northeast-1" "ap-northeast-2" "ap-southeast-1" "ap-southeast-2" "sa-east-1")

"${AWS}" iam list-server-certificates --output text  \
    --query 'sort_by(ServerCertificateMetadataList,&Expiration)[].[Expiration,ServerCertificateName]' $@ > "${TMPCERTLIST}"

while read certentry; do
    expiry=$("${ECHO}" "${certentry}" | "${CUT}" -f 1)
    expiry="$(${DATE} -d ${expiry} +%s)"
    certname=$("${ECHO}" "${certentry}" | "${CUT}" -f 2)

    # check if cert is expired
    if [ "${CURRENTDATE}" -gt "${expiry}" ]; then

        # check if cert is still in use and abort if it is in use
        for region in "${AWSREGIONS[@]}"; do
            "${AWS}" elb describe-load-balancers --region="${region}" --output text | "${GREP}" -q "${certname}"

            # the cert is still in use by one ELB, do not remove
            if [ $? -eq 0 ]; then
                "${ECHO}" "ERROR: certname:" "${certname}" " is in use by a ELB"
                # breaking out of for while loop - continue to check the next cert
                continue 2
            fi
        done
        "${AWS}" iam delete-server-certificate --server-certificate-name "${certname}" $@
    fi
done < "${TMPCERTLIST}"


/bin/rm "${TMPCERTLIST}"
exit 0
