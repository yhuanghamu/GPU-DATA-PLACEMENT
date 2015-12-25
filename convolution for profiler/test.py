#!/usr/bin/python

import os

# traverse root directory, and list directories as dirs and files as files
for root, dirs,files in os.walk("."):
 for x in dirs:
  sttring = "cp 2.cu "+"/home/scratch/gchen01/0/"+str(x)
  os.system(sttring)
