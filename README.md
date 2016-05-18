# aws-scripts

Collection of useful AWS scripts for automation.

## iam/iam-certs-cleanup.sh

`iam/iam-certs-cleanup.sh` will go through your provisioned certificates in IAM and find those who are expired.
Additional checks are performed against all provisioned ELBs in all availability zones to make sure the expired certs
are not used anywhere else.
For cross profile usage, please execute `iam/iam-certs-cleanup.sh --profile xxx`
