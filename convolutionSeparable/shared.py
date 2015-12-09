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
alfa = 1
dimension = [2,2,2]
sizeof = [4, 4, 4]
block_X = [3072,3072,3072]
block_Y = [256,256,256]
stride = []
for line in open(sys.argv[1],'r'):
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
  continue 
stride.sort(
key = lambda l:(l[0],l[1],l[2],l[3],l[5])
)

L1_cache_line = 128
L1_size = 16*1024
L2_cache_line = 32
L2_size = 768*1024
if L2_cache_line < L1_cache_line:
 L2_cache_line = L1_cache_line
L1_lines = L1_size/L1_cache_line
L2_lines = L2_size/L2_cache_line
x=0
array = int(stride[x][0])
array_next = array
rw = int(stride[x][1])
exp = int(stride[x][2])
loop = int(stride[x][3])
index = int(stride[x][5])
warp = int(stride[x][4])
print1 = 0
cache_line = 32
#array_total=[]
flag = 0
total = 0
total_cache_line=0
access = []
access_cache_line = []
collect = []
collect_total = []
L1_hit = 0
L2_hit = 0
L1 = []
L2 = []
while x<len(stride):
 array_next = int(stride[x][0])
 rw_next = int(stride[x][1])
 exp_next = int(stride[x][2])
 loop_next = int(stride[x][3])
 warp_next = int(stride[x][4])
 index_next = int(stride[x][5])

 x = x + 1
 #if warp_next >=32:
 # continue

 if (array == array_next):
  
  if index_next not in collect:
   collect.append(index_next)
  
  #if index_next*sizeof[array_next]/cache_line not in collect_cache_line:
  # collect_cache_line.append(index_next*sizeof[array_next]/cache_line)
 else:
  collect.sort()
  collect_total.append(collect)
  collect_cache_line = []
  total = len(collect)
  for i in collect:
   if i*sizeof[array]/cache_line  in L1 and i*sizeof[array]/cache_line not in collect_cache_line and math.fabs(len(L1)-L1.index(i*sizeof[array]/L1_cache_line)) <= L1_lines:
    L1_hit += 1
    L1.remove(i*sizeof[array]/cache_line)
    L1.append(i*sizeof[array]/cache_line)
   elif i*sizeof[array]/cache_line not in collect_cache_line:
    if i*sizeof[array]/cache_line in L1:
     L1.remove(i*sizeof[array]/cache_line)
    L1.append(i*sizeof[array]/cache_line)
    if i*sizeof[array]/L2_cache_line  in L2 and i*sizeof[array]/cache_line not in collect_cache_line and math.fabs(len(L2)-L2.index(i*sizeof[array]/L2_cache_line)) <= L2_lines:
     L2_hit += 1
     L2.remove(i*sizeof[array]/L2_cache_line)
     L2.append(i*sizeof[array]/L2_cache_line)
    elif i*sizeof[array]/cache_line not in collect_cache_line:
     if i*sizeof[array]/L2_cache_line  in L2:
      L2.remove(i*sizeof[array]/L2_cache_line)
     L2.append(i*sizeof[array]/L2_cache_line)
   if i*sizeof[array]/cache_line not in collect_cache_line:
    collect_cache_line.append(i*sizeof[array]/cache_line)
  total_cache_line = len(collect_cache_line)
  print("Array "+str(array)+" put in shared memory has "+str(total)+ " latency")
  print("Array "+str(array)+" put in shared memory has "+str(total_cache_line)+ " cold latency")
  print("Array "+str(array)+" put in shared memory has "+str(L1_hit)+ " L1_hits")
  print("Array "+str(array)+" put in shared memory has "+str(L2_hit)+ " L2_hits")
  if len(collect)>6 * 1024/ sizeof[array]:
   total_2 = 9999999
  else: 
   total_2 = x - flag - total

  print("Array "+str(array)+" accessed in  shared memory has "+str(total_2)+ " shared latency")
  flag = x
  total = 0
  L1_hit =0
  L2_hit = 0
  collect = []
  clolect_cache_line = []
  array = array_next
  collect.append(index_next)
  collect_cache_line.append(index_next*sizeof[array]/cache_line)
  L1.append(index_next*sizeof[array]/cache_line)
  L2.append(index_next*sizeof[array]/L2_cache_line)
collect.sort()
collect_total.append(collect)
collect_cache_line = []
total = len(collect)
for i in collect:
 if i*sizeof[array]/cache_line  in L1 and i*sizeof[array]/cache_line not in collect_cache_line and math.fabs(len(L1)-L1.index(i*sizeof[array]/L1_cache_line)) <= L1_lines:
  print(L1)
  L1_hit += 1
  L1.remove(i*sizeof[array]/cache_line)
  L1.append(i*sizeof[array]/cache_line)
 elif i*sizeof[array]/cache_line not in collect_cache_line:
  if i*sizeof[array]/cache_line in L1:
   L1.remove(i*sizeof[array]/cache_line)
  L1.append(i*sizeof[array]/cache_line)
  if i*sizeof[array]/L2_cache_line  in L2 and i*sizeof[array]/cache_line not in collect_cache_line and math.fabs(len(L2)-L2.index(i*sizeof[array]/L2_cache_line)) <= L2_lines:
   L2_hit += 1
   L2.remove(i*sizeof[array]/L2_cache_line)
   L2.append(i*sizeof[array]/L2_cache_line)
  elif i*sizeof[array]/cache_line not in collect_cache_line:
   if i*sizeof[array]/L2_cache_line  in L2:
    L2.remove(i*sizeof[array]/L2_cache_line)
   L2.append(i*sizeof[array]/L2_cache_line)
 if i*sizeof[array]/cache_line not in collect_cache_line:
  collect_cache_line.append(i*sizeof[array]/cache_line)
total_cache_line = len(collect_cache_line)
print("Array "+str(array)+" put in shared memory has "+str(total)+ " latency")
print("Array "+str(array)+" put in shared memory has "+str(total_cache_line)+ " cold latency")
print("Array "+str(array)+" put in shared memory has "+str(L1_hit)+ " L1_hits")
print("Array "+str(array)+" put in shared memory has "+str(L2_hit)+ " L2_hits")
if len(collect)>6 * 1024/ sizeof[array]:
 total_2 = 9999999
 print("Array "+str(array)+" can not be put in shared memory!")
else:
 total_2 = x + 1 - flag - total
 print(x)
 print(flag)
 print("Array "+str(array)+" accessed in shared memory has "+str(total_2)+ " shared latency")

