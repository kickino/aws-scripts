#!/bin/sh

ECHO="/bin/echo"
CUT="/usr/bin/cut"
DATE="/bin/date"
AWS="/usr/local/bin/aws"

TMPCERTLIST="/tmp/aws_certlist"
CURRENTDATE=$("${DATE}" +%s)

"${AWS}" iam list-server-certificates --output text  \
    --query 'sort_by(ServerCertificateMetadataList,&Expiration)[].[Expiration,ServerCertificateName]' $@ > "${TMPCERTLIST}"

while read certentry; do
    expiry=$("${ECHO}" "${certentry}" | "${CUT}" -f 1)
    expiry="$(${DATE} -d ${expiry} +%s)"
    certname=$("${ECHO}" "${certentry}" | "${CUT}" -f 2)

    if [ "${CURRENTDATE}" -gt "${expiry}" ]; then
        "${AWS}" iam delete-server-certificate --server-certificate-name "${certname}" $@
    fi
done < "${TMPCERTLIST}"


/bin/rm "${TMPCERTLIST}"
exit 0
