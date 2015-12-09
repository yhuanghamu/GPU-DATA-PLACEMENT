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
dimension = [1,1,1]
sizeof = [12, 4, 12]

stride = []
for line in open(sys.argv[1],'r'):
 thread = line.strip()
 if thread[0].isdigit():
  thread = thread.split()
  for x in range(0,len(thread)):
   thread[x] = int(thread[x])
  stride.append(thread)

stride.sort(
key = lambda l:(l[0],l[1],l[2],l[3],l[5])
)
#for x in stride:
 #print(x)
#################################
   
#      Constant Memory

#################################
print("###########################")
print("          Constant Memory                 ")
print("###########################")
x=0
array = 0
array_next = 0
rw = 0
exp = 0
loop = 0
index = 0
warp = -1
print1 = 0
cache_line = 128
#array_total=[]
total = 0
total_cache_line=0
access = []
access_cache_line = []
collect = []
collect_cache_line = [] 
while x<len(stride):
 array_next = int(stride[x][0])
 rw_next = int(stride[x][1])
 exp_next = int(stride[x][2])
 loop_next = int(stride[x][3])
 warp_next = int(stride[x][4])
 index_next = int(stride[x][5])
 x = x + 1
 if (array == array_next):
  if(rw_next == 0):
   if (exp == exp_next):
    
    if (loop == loop_next):
     if index_next not in collect:
      collect.append(index_next)
      index = index_next
     if index_next*sizeof[array_next]/cache_line not in collect_cache_line:
      collect_cache_line.append(index_next*sizeof[array_next]/cache_line)
    else:
     loop = loop_next
     access.append(len(collect))
     collect = []
     collect.append(index_next)
     access_cache_line.append(len(collect_cache_line))
     collect_cache_line = []
     collect_cache_line.append(index_next*sizeof[array_next]/cache_line)
   else:
   
    access.append(len(collect))
    collect = []
    collect.append(index_next)
    access_cache_line.append(len(collect_cache_line))
    collect_cache_line = []
    collect_cache_line.append(index_next*sizeof[array_next]/cache_line)
    exp = exp_next
    loop = 0
  else:
   access = []
   access_cache_line = []
   collect_cache_line=[]
   collect = []
   loop = 0
   exp = 0
   total = 99999999
   if(print1 == 0):
    print("array "+str(array)+" can only be put in shared memory or global memory")
    print1 += 1
 else:  
  access.append(len(collect))
  access_cache_line.append(len(collect_cache_line))
  for i in access:
   total += i
  print("Array "+str(array)+" put in constant memory has "+str(total)+ " latency")
  for i in access_cache_line:
   total_cache_line += i
  print("Array "+str(array)+" put in constant memory has "+str(total_cache_line)+ " cold latency!")
  array = array_next
  access = []
  access_cache_line = []
  collect_cache_line=[]
  collect = []
  collect.append(index_next)
  collect_cache_line.append(index_next*sizeof[array_next]/cache_line)
  exp = 0
  loop = 0
  total = 0
  total_cache_line=0

access.append(len(collect))
access_cache_line.append(len(collect_cache_line))
for i in access:
 total += i
for i in access_cache_line:
 total_cache_line += i 
print("Array "+str(array_next)+" put in constant memory has "+str(total)+ " latency")
print("Array "+str(array_next)+" put in constant memory has "+str(total_cache_line)+ " cold latency")

#############################################################################################################################################################################
#############################################################          Global Memroy  #######################################################################################
############################################################################################################################################################################@
print("###########################")
print("          Global Memory                 ")
print("###########################")
x=0
array = 0
array_next = 0
rw = 0
exp = 0
loop = 0
index = 0
warp = -1
print1 = 0
cache_line = 32
#array_total=[]
flag = 0
total = 0
total_cache_line=0
access = []
access_cache_line = []
collect = []
collect_cache_line = []
while x<len(stride):
 array_next = int(stride[x][0])
 rw_next = int(stride[x][1])
 exp_next = int(stride[x][2])
 loop_next = int(stride[x][3])
 warp_next = int(stride[x][4])
 index_next = int(stride[x][5])
 x = x + 1
 if (array == array_next):
  if(rw_next == rw):
   if (exp == exp_next):

    if (loop == loop_next):
     if index_next not in collect:
      collect.append(index_next)
      index = index_next
     if index_next*sizeof[array_next]/cache_line not in collect_cache_line:
      collect_cache_line.append(index_next*sizeof[array_next]/cache_line)
    else:
     loop = loop_next
     access.append(len(collect))
     collect = []
     collect.append(index_next)
     access_cache_line.append(1+(len(collect_cache_line)-1)*0.2)
     collect_cache_line = []
     collect_cache_line.append(index_next*sizeof[array_next]/cache_line)
   else:

    access.append(len(collect))
    collect = []
    collect.append(index_next)
    access_cache_line.append(1+(len(collect_cache_line)-1)*0.2)
    collect_cache_line = []
    collect_cache_line.append(index_next*sizeof[array_next]/cache_line)
    exp = exp_next
    loop = 0
  else:
   access = []
   access_cache_line = []
   collect_cache_line=[]
   collect = []
   loop = 0
   exp = 0
   total = 99999999
   if(print1 == 0):
    print("array "+str(array)+" can only be put in shared memory or global memory")
    print1 += 1
 else:
  rw = rw_next
  access.append(len(collect))
  access_cache_line.append(1+(len(collect_cache_line)-1)*0.2)
  for i in access:
   total += i
  print("Array "+str(array)+" put in global memory has "+str(total)+ " latency")
  for i in access_cache_line:
   total_cache_line += i
  print("Array "+str(array)+" put in global  memory has "+str(total_cache_line)+ " cold latency!")
  array = array_next
  access = []
  access_cache_line = []
  collect_cache_line=[]
  collect = []
  collect.append(index_next)
  collect_cache_line.append(index_next*sizeof[array_next]/cache_line)
  exp = 0
  loop = 0
  total = 0
  total_cache_line=0
access.append(len(collect))
access_cache_line.append(1+(len(collect_cache_line)-1)*0.2)
print(access_cache_line)
for i in access:
 total += i
for i in access_cache_line:
 total_cache_line += i
print("Array "+str(array_next)+" put in global memory has "+str(total)+ " latency")
print("Array "+str(array_next)+" put in global memory has "+str(total_cache_line)+ " cold latency")

print("###########################")
print("          Texture  Memory                 ")
print("###########################")
x=0
array = 0
array_next = 0
rw = 0
exp = 0
loop = 0
index = 0
warp = -1
print1 = 0
cache_line = 128
#array_total=[]
flag = 0
total = 0
total_cache_line=0
access = []
access_cache_line = []
collect = []
collect_cache_line = []
while x<len(stride):
 array_next = int(stride[x][0])
 rw_next = int(stride[x][1])
 exp_next = int(stride[x][2])
 loop_next = int(stride[x][3])
 warp_next = int(stride[x][4])
 index_next = int(stride[x][5])
 x = x + 1
 if (array == array_next):
  if(rw_next == 0):
   if (exp == exp_next):

    if (loop == loop_next):
     if index_next not in collect:
      collect.append(index_next)
      index = index_next
     if index_next*sizeof[array_next]/cache_line not in collect_cache_line:
      collect_cache_line.append(index_next*sizeof[array_next]/cache_line)
    else:
     loop = loop_next
     access.append(len(collect))
     collect = []
     collect.append(index_next)
     access_cache_line.append(1+(len(collect_cache_line)-1)*0.2)
     collect_cache_line = []
     collect_cache_line.append(index_next*sizeof[array_next]/cache_line)
   else:

    access.append(len(collect))
    collect = []
    collect.append(index_next)
    access_cache_line.append(1+(len(collect_cache_line)-1)*0.2)
    collect_cache_line = []
    collect_cache_line.append(index_next*sizeof[array_next]/cache_line)
    exp = exp_next
    loop = 0
  else:
   access = []
   access_cache_line = []
   collect_cache_line=[]
   collect = []
   loop = 0
   exp = 0
   total = 99999999
   if(print1 == 0):
    print("array "+str(array)+" can only be put in shared memory or global memory")
    print1 += 1
 else:
  
  access.append(len(collect))
  access_cache_line.append(1+(len(collect_cache_line)-1)*0.2)
  for i in access:
   total += i
  if dimension[array_next] == 1:
   print("Array "+str(array)+" put in texture memory has "+str(total)+ " latency")
  for i in access_cache_line:
   total_cache_line += i
  if dimension[array_next] == 1:
   print("Array "+str(array)+" put in texture memory has "+str(total_cache_line)+ " cold latency!")
  array = array_next
 # rw = rw_next
  access = []
  access_cache_line = []
  collect_cache_line=[]
  collect = []
  collect.append(index_next)
  collect_cache_line.append(index_next*sizeof[array_next]/cache_line)
  exp = 0
  loop = 0
  total = 0
  total_cache_line=0
access.append(len(collect))
access_cache_line.append(1+(len(collect_cache_line)-1)*0.2)
for i in access:
 total += i
for i in access_cache_line:
 total_cache_line += i
if dimension[array_next] == 1:
 print("Array "+str(array_next)+" put in texture memory has "+str(total)+ " latency")
if dimension[array_next] == 1:
 print("Array "+str(array_next)+" put in texture memory has "+str(total_cache_line)+ " cold latency")

print("###########################")
print("          Shared  Memory                 ")
print("###########################")
x=0
array = 0
array_next = 0
rw = 0
exp = 0
loop = 0
index = 0
warp = -1
print1 = 0
cache_line = 32
#array_total=[]
flag = 0
total = 0
total_cache_line=0
access = []
access_cache_line = []
collect = []
collect_cache_line = []
while x<len(stride):
 array_next = int(stride[x][0])
 rw_next = int(stride[x][1])
 exp_next = int(stride[x][2])
 loop_next = int(stride[x][3])
 warp_next = int(stride[x][4])
 index_next = int(stride[x][5])
 x = x + 1
 if (array == array_next):
  
  if index_next not in collect:
   collect.append(index_next)
  #if index_next*sizeof[array_next]/cache_line not in collect_cache_line:
  # collect_cache_line.append(index_next*sizeof[array_next]/cache_line)
 else:
  collect.sort()
  collect_cache_line = []
  total = len(collect)
  for i in collect:
   if i*sizeof[array]/cache_line not in collect_cache_line:
    collect_cache_line.append(i*sizeof[array]/cache_line)
  total_cache_line = len(collect_cache_line)
  print("Array "+str(array)+" put in shared memory has "+str(total)+ " latency")
  print("Array "+str(array)+" put in shared memory has "+str(total_cache_line)+ " cold latency")
  if (collect[-1]- collect[0])>6 * 1024/ sizeof[array]:
   total_2 = 9999999
  else: 
   total_2 = x - flag - total

  print("Array "+str(array)+" accessed in  shared memory has "+str(total_2)+ " shared latency")
  flag = x
  total = 0
  collect = []
  clolect_cache_line = []
  array = array_next
  collect.append(index_next)
  collect_cache_line.append(index_next*sizeof[array]/cache_line)
collect.sort()
collect_cache_line = []
total = len(collect)
for i in collect:
 if i*sizeof[array]/cache_line not in collect_cache_line:
  collect_cache_line.append(i*sizeof[array]/cache_line)
total_cache_line = len(collect_cache_line)
print("Array "+str(array)+" put in shared memory has "+str(total)+ " latency")
print("Array "+str(array)+" put in shared memory has "+str(total_cache_line)+ " cold latency")
if (collect[-1]- collect[0])>6 * 1024/ sizeof[array]:
 total_2 = 9999999
else:
 total_2 = x+1 - flag - total
print("Array "+str(array)+" accessed in  shared memory has "+str(total_2)+ " shared latency")
