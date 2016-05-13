#!/usr/bin/python2.7


from boto.glacier.layer1 import Layer1
from boto.glacier.concurrent import ConcurrentUploader
import sys
import os.path

from time import gmtime, strftime

access_key_id = "xxx"
secret_key = "xxx"
target_vault_name = "xxx"

# the file to be deleted
archive_id = sys.argv[1]

 
glacier_layer1 = Layer1(aws_access_key_id=access_key_id, aws_secret_access_key=secret_key, is_secure=True)
glacier_layer1.delete_archive(target_vault_name, archive_id)

sys.exit(0);

