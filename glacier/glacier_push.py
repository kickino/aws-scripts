#!/usr/bin/python2.7


from boto.glacier.layer1 import Layer1
from boto.glacier.concurrent import ConcurrentUploader
import sys
import os.path

from time import gmtime, strftime

access_key_id = "xxx"
secret_key = "xxx"
target_vault_name = "xxx"
inventory = "xxx"

# the file to be uploaded into the vault as an archive
fname = sys.argv[1]

# a description you give to the file
fdes = os.path.basename(sys.argv[1])
 
if not os.path.isfile(fname) :
    print("Can't find the file to upload")
    sys.exit(-1);

# glacier uploader 
glacier_layer1 = Layer1(aws_access_key_id=access_key_id, aws_secret_access_key=secret_key, is_secure=True)
uploader = ConcurrentUploader(glacier_layer1, target_vault_name, part_size=128*1024*1024, num_threads=1)
archive_id = uploader.upload(fname, fdes)

# write an inventory file
f = open(inventory, 'a+')
f.write(archive_id+'\t'+fdes+'\n')
f.close()

sys.exit(0);
