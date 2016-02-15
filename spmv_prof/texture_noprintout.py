#!/usr/bin/python

"""
usage: ./analysis.py *.txt dimension 
"""

import sys
import os
import re
from itertools import *
import time
import math

dimension =[]# [2,2,2]
sizeof = []#[4, 4, 4]
block_X = []#[3072,3072,3072]
block_Y = []#[256,256,256]
array_size = []
stride = []
for line in open(sys.argv[10],'r'):
 thread = line.strip()
 if thread[0].isdigit():
  thread = thread.split()
  for x in range(0,len(thread)):
   thread[x] = int(thread[x])
  stride.append(thread)
 elif  thread[0] == '[':
  while thread[0]!= ':':
   thread = thread[1:]
  thread = thread[1:]
  thread = thread.split()
  for x in range(0,len(thread)):
   thread[x] = int(thread[x])
  stride.append(thread)
 else:
  thread = thread.split()
  for i in range(1,len(thread)):
   thread[i] = int(thread[i])
  if thread[0] == "dimension":
   dimension = thread[1:]
  elif thread[0]=="sizeof":
   sizeof = thread[1:]
  elif thread[0] =="block_X":
   block_X = thread[1:]
  elif thread[0] == "block_Y":
   block_Y = thread[1:]
  elif thread[0] == "array_size":
   array_size = thread[1:]
  else:
   continue

if dimension[0] == 1:
 exe_command = "./1Dtexture_noprint.py "+sys.argv[1]+" "+sys.argv[3]+" "+sys.argv[4]+" "+sys.argv[5]+" "+sys.argv[6]+" "+sys.argv[7]+" "+sys.argv[8]+" "+sys.argv[9]+" "+sys.argv[10]
 os.system(exe_command)
 printout = "texture2D"
 for x in sizeof:
  printout += " 99999999 0 0"
 out = open("output.txt",'a')
 printout += "\n"
 out.write(printout)
 out.close()
elif dimension[0] == 2:
 exe_command = "./1Dtexture_noprint.py "+sys.argv[1]+" "+sys.argv[3]+" "+sys.argv[4]+" "+sys.argv[5]+" "+sys.argv[6]+" "+sys.argv[7]+" "+sys.argv[8]+" "+sys.argv[9]+" "+sys.argv[10]
 os.system(exe_command)
 exe_command = "./2Dtexture_noprintout.py "+sys.argv[1]+" "+sys.argv[2]+" "+sys.argv[3]+" "+sys.argv[4]+" "+sys.argv[5]+" "+sys.argv[6]+" "+sys.argv[7]+" "+sys.argv[8]+" "+sys.argv[9]+" "+sys.argv[10]
 os.system(exe_command)
