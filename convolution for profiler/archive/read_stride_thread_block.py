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
key = lambda l:(l[0],l[1],l[2],l[3],l[4])
)


#for x in stride:
# print(x)
#################################
   
#      Constant Memory

#################################
print("###########################")
print("          Constant Memory                 ")
print("###########################")
L1_cache_line = 64
L1_size = 2*1024
L2_cache_line = 256
L2_size = 32*1024
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
cache_line = L1_cache_line
#array_total=[]
total = 0
total_cache_line=0
access = []
access_cache_line = []
collect = []
collect_cache_line = [] 
temporal_cache_line = []
L1 = []
L2 = []
L1_hit = 0
L2_hit = 0
temporal_hit = 0
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
  if(rw_next == 0):
   if (exp == exp_next):
   
    if (loop == loop_next):
     if ((warp/32) == (warp_next/32)):
      if index_next not in collect:
       collect.append(index_next)
       index = index_next
      if index_next*sizeof[array_next]/cache_line in temporal_cache_line and index_next*sizeof[array_next]/cache_line not in collect_cache_line:
       temporal_hit += 1
      if index_next*sizeof[array_next]/L1_cache_line in L1 and index_next*sizeof[array_next]/cache_line not in collect_cache_line and  math.fabs(len(L1)-L1.index(index_next*sizeof[array_next]/L1_cache_line)) <= L1_lines:
       L1_hit += 1
       L1.remove(index_next*sizeof[array_next]/L1_cache_line)
       L1.append(index_next*sizeof[array_next]/L1_cache_line)
      elif index_next*sizeof[array_next]/cache_line not in collect_cache_line:
       if index_next*sizeof[array_next]/L1_cache_line in L1:
        L1.remove(index_next*sizeof[array_next]/L1_cache_line)
       L1.append(index_next*sizeof[array_next]/L1_cache_line)
       if index_next*sizeof[array_next]/L2_cache_line in L2 and \
          index_next*sizeof[array_next]/cache_line not in collect_cache_line and \
          math.fabs(len(L2)-L2.index(index_next*sizeof[array_next]/L2_cache_line)) <= L2_lines:
          L2_hit += 1
          L2.remove(index_next*sizeof[array_next]/L2_cache_line)
          L2.append(index_next*sizeof[array_next]/L2_cache_line)
       else:
        if index_next*sizeof[array_next]/L2_cache_line in L2:
         L2.remove(index_next*sizeof[array_next]/L2_cache_line)
        L2.append(index_next*sizeof[array_next]/L2_cache_line)


      if index_next*sizeof[array_next]/cache_line not in temporal_cache_line:
       temporal_cache_line.append(index_next*sizeof[array_next]/cache_line)
	    

      if index_next*sizeof[array_next]/cache_line not in collect_cache_line:
       collect_cache_line.append(index_next*sizeof[array_next]/cache_line)
    # if (array == 1) and index_next not in collect and index_next*sizeof[array_next]/cache_line in collect_cache_line:
     else:
      warp = warp_next
      access.append(len(collect))
      collect = []
      collect.append(index_next)
      access_cache_line.append(len(collect_cache_line))
      collect_cache_line=[]
      index = index_next
      if index_next*sizeof[array_next]/cache_line in temporal_cache_line and index_next*sizeof[array_next]/cache_line not in collect_cache_line:
       temporal_hit += 1
      if index_next*sizeof[array_next]/L1_cache_line in L1 and index_next*sizeof[array_next]/cache_line not in collect_cache_line and  math.fabs(len(L1)-L1.index(index_next*sizeof[array_next]/L1_cache_line)) <= L1_lines:
       L1_hit += 1
       L1.remove(index_next*sizeof[array_next]/L1_cache_line)
       L1.append(index_next*sizeof[array_next]/L1_cache_line)
      elif index_next*sizeof[array_next]/cache_line not in collect_cache_line:
       if index_next*sizeof[array_next]/L1_cache_line in L1:
        L1.remove(index_next*sizeof[array_next]/L1_cache_line)
       L1.append(index_next*sizeof[array_next]/L1_cache_line)
       if index_next*sizeof[array_next]/L2_cache_line in L2 and \
          index_next*sizeof[array_next]/cache_line not in collect_cache_line and \
          math.fabs(len(L2)-L2.index(index_next*sizeof[array_next]/L2_cache_line)) <= L2_lines:
          L2_hit += 1
          L2.remove(index_next*sizeof[array_next]/L2_cache_line)
          L2.append(index_next*sizeof[array_next]/L2_cache_line)
       else:
        if index_next*sizeof[array_next]/L2_cache_line in L2:
         L2.remove(index_next*sizeof[array_next]/L2_cache_line)
        L2.append(index_next*sizeof[array_next]/L2_cache_line)


      if index_next*sizeof[array_next]/cache_line not in temporal_cache_line:
       temporal_cache_line.append(index_next*sizeof[array_next]/cache_line)
      collect_cache_line.append(index_next*sizeof[array_next]/cache_line)
    else:
     loop = loop_next
     warp = warp_next
     access.append(len(collect))
     
     collect = []
     collect.append(index_next)
     access_cache_line.append(len(collect_cache_line))
     collect_cache_line = []
     if index_next*sizeof[array_next]/L1_cache_line in L1 and index_next*sizeof[array_next]/cache_line not in collect_cache_line and  math.fabs(len(L1)-L1.index(index_next*sizeof[array_next]/L1_cache_line)) <= L1_lines:
      L1_hit += 1
      L1.remove(index_next*sizeof[array_next]/L1_cache_line)
      L1.append(index_next*sizeof[array_next]/L1_cache_line)
     elif index_next*sizeof[array_next]/cache_line not in collect_cache_line:
      if index_next*sizeof[array_next]/L1_cache_line in L1:
       L1.remove(index_next*sizeof[array_next]/L1_cache_line)
      L1.append(index_next*sizeof[array_next]/L1_cache_line)
      if index_next*sizeof[array_next]/L2_cache_line in L2 and \
         index_next*sizeof[array_next]/cache_line not in collect_cache_line and \
         math.fabs(len(L2)-L2.index(index_next*sizeof[array_next]/L2_cache_line)) <= L2_lines:
       L2_hit += 1
       L2.remove(index_next*sizeof[array_next]/L2_cache_line)
       L2.append(index_next*sizeof[array_next]/L2_cache_line)
      else:
       if index_next*sizeof[array_next]/L2_cache_line in L2:
        L2.remove(index_next*sizeof[array_next]/L2_cache_line)
       L2.append(index_next*sizeof[array_next]/L2_cache_line)
     if index_next*sizeof[array_next]/cache_line in temporal_cache_line and index_next*sizeof[array_next]/cache_line not in collect_cache_line:
      temporal_hit += 1
     collect_cache_line.append(index_next*sizeof[array_next]/cache_line)
     if index_next*sizeof[array_next]/cache_line not in temporal_cache_line:
      temporal_cache_line.append(index_next*sizeof[array_next]/cache_line)
   else:
   
    access.append(len(collect))
    collect = []
    collect.append(index_next)
    access_cache_line.append(len(collect_cache_line))
    collect_cache_line = []
    if index_next*sizeof[array_next]/L1_cache_line in L1 and index_next*sizeof[array_next]/cache_line not in collect_cache_line and  math.fabs(len(L1)-L1.index(index_next*sizeof[array_next]/L1_cache_line)) <= L1_lines:
     L1_hit += 1
     L1.remove(index_next*sizeof[array_next]/L1_cache_line)
     L1.append(index_next*sizeof[array_next]/L1_cache_line)
    elif index_next*sizeof[array_next]/cache_line not in collect_cache_line:
     if index_next*sizeof[array_next]/L1_cache_line in L1:
      L1.remove(index_next*sizeof[array_next]/L1_cache_line)
     L1.append(index_next*sizeof[array_next]/L1_cache_line)
     if index_next*sizeof[array_next]/L2_cache_line in L2 and \
        index_next*sizeof[array_next]/cache_line not in collect_cache_line and \
        math.fabs(len(L2)-L2.index(index_next*sizeof[array_next]/L2_cache_line)) <= L2_lines:
      L2_hit += 1
      L2.remove(index_next*sizeof[array_next]/L2_cache_line)
      L2.append(index_next*sizeof[array_next]/L2_cache_line)
     else:
      if index_next*sizeof[array_next]/L2_cache_line in L2:
       L2.remove(index_next*sizeof[array_next]/L2_cache_line)
      L2.append(index_next*sizeof[array_next]/L2_cache_line)
    if index_next*sizeof[array_next]/cache_line in temporal_cache_line and index_next*sizeof[array_next]/cache_line not in collect_cache_line:
     temporal_hit += 1
    collect_cache_line.append(index_next*sizeof[array_next]/cache_line)
    if index_next*sizeof[array_next]/cache_line not in temporal_cache_line:
     temporal_cache_line.append(index_next*sizeof[array_next]/cache_line)
    exp = exp_next
    loop = loop_next
    warp = warp_next
  else:
   access = []
   access_cache_line = []
   collect_cache_line=[]
   collect = []
   temporal_hit = 0
   L1 = []
   L2 = []
   L1_hit = 0
   L2_hit = 0

   temporal_cache_line = []
   loop = loop_next
   exp = exp_next
   warp = warp_next
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
  print("Array "+str(array)+" put in constant memory has "+str(temporal_hit)+" temporal hits")
  print("Array "+str(array)+" put in constant memory has "+str(L1_hit)+" L1 hits")
  print("Array "+str(array)+" put in constant memory has "+str(L2_hit)+" L2 hits")
  array = array_next
  access = []
  temporal_hit = 0
  temporal_cache_line = []
  L1 = []
  L2 = []
  L1_hit = 0
  L2_hit = 0

  access_cache_line = []
  collect_cache_line=[]
  collect = []
  collect.append(index_next)
  collect_cache_line.append(index_next*sizeof[array_next]/cache_line)
  temporal_cache_line.append(index_next*sizeof[array_next]/cache_line)
  L1.append(index_next*sizeof[array_next]/L1_cache_line)
  L2.append(index_next*sizeof[array_next]/L2_cache_line)
  exp = exp_next
  loop = loop_next
  warp = warp_next
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
print("Array "+str(array_next)+" put in constant  memory has "+str(temporal_hit)+ " temporal hits ")
print("Array "+str(array)+" put in constant memory has "+str(L1_hit)+" L1 hits")
print("Array "+str(array)+" put in constant memory has "+str(L2_hit)+" L2 hits")
#############################################################################################################################################################################
#############################################################          Global Memroy  #######################################################################################
############################################################################################################################################################################@
print("###########################")
print("          Global Memory                 ")
print("###########################")

L1_cache_line = 32
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
cache_line = L1_cache_line
#array_total=[]
total = 0
total_cache_line=0
access = []
access_cache_line = []
collect = []
collect_cache_line = [] 
temporal_cache_line = []
L1 = []
L2 = []
L1_hit = 0
L2_hit = 0
temporal_hit = 0
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
  if(rw_next == rw):
   if (exp == exp_next):
   
    if (loop == loop_next):
     if ((warp/32) == (warp_next/32)):
      if index_next not in collect:
       collect.append(index_next)
       index = index_next
      if index_next*sizeof[array_next]/cache_line in temporal_cache_line and index_next*sizeof[array_next]/cache_line not in collect_cache_line:
       temporal_hit += 1
      if (rw_next == 0) and index_next*sizeof[array_next]/L1_cache_line in L1 and index_next*sizeof[array_next]/cache_line not in collect_cache_line and  math.fabs(len(L1)-L1.index(index_next*sizeof[array_next]/L1_cache_line)) <= L1_lines:
       L1_hit += 1
       L1.remove(index_next*sizeof[array_next]/L1_cache_line)
       L1.append(index_next*sizeof[array_next]/L1_cache_line)
      elif index_next*sizeof[array_next]/cache_line not in collect_cache_line:
       if rw_next == 0:
        if index_next*sizeof[array_next]/L1_cache_line in L1:
         L1.remove(index_next*sizeof[array_next]/L1_cache_line)
        L1.append(index_next*sizeof[array_next]/L1_cache_line)
       if index_next*sizeof[array_next]/L2_cache_line in L2 and \
          index_next*sizeof[array_next]/cache_line not in collect_cache_line and \
          math.fabs(len(L2)-L2.index(index_next*sizeof[array_next]/L2_cache_line)) <= L2_lines:
          L2_hit += 1
          L2.remove(index_next*sizeof[array_next]/L2_cache_line)
          L2.append(index_next*sizeof[array_next]/L2_cache_line)
       else:
        if index_next*sizeof[array_next]/L2_cache_line in L2:
         L2.remove(index_next*sizeof[array_next]/L2_cache_line)
        L2.append(index_next*sizeof[array_next]/L2_cache_line)


      if index_next*sizeof[array_next]/cache_line not in temporal_cache_line:
       temporal_cache_line.append(index_next*sizeof[array_next]/cache_line)
	    

      if index_next*sizeof[array_next]/cache_line not in collect_cache_line:
       collect_cache_line.append(index_next*sizeof[array_next]/cache_line)
    # if (array == 1) and index_next not in collect and index_next*sizeof[array_next]/cache_line in collect_cache_line:
     else:
      warp = warp_next
      access.append(len(collect))
      collect = []
      collect.append(index_next)
      access_cache_line.append(1+(len(collect_cache_line)-1)*alfa)
      collect_cache_line=[]
      index = index_next
      if index_next*sizeof[array_next]/cache_line in temporal_cache_line and index_next*sizeof[array_next]/cache_line not in collect_cache_line:
       temporal_hit += 1
      if (rw_next == 0) and index_next*sizeof[array_next]/L1_cache_line in L1 and index_next*sizeof[array_next]/cache_line not in collect_cache_line and  math.fabs(len(L1)-L1.index(index_next*sizeof[array_next]/L1_cache_line)) <= L1_lines:
       L1_hit += 1
       L1.remove(index_next*sizeof[array_next]/L1_cache_line)
       L1.append(index_next*sizeof[array_next]/L1_cache_line)
      elif index_next*sizeof[array_next]/cache_line not in collect_cache_line:
       if rw_next == 0:
        if index_next*sizeof[array_next]/L1_cache_line in L1:
         L1.remove(index_next*sizeof[array_next]/L1_cache_line)
        L1.append(index_next*sizeof[array_next]/L1_cache_line)
       if index_next*sizeof[array_next]/L2_cache_line in L2 and \
          index_next*sizeof[array_next]/cache_line not in collect_cache_line and \
          math.fabs(len(L2)-L2.index(index_next*sizeof[array_next]/L2_cache_line)) <= L2_lines:
          L2_hit += 1
          L2.remove(index_next*sizeof[array_next]/L2_cache_line)
          L2.append(index_next*sizeof[array_next]/L2_cache_line)
       else:
        if index_next*sizeof[array_next]/L2_cache_line in L2:
         L2.remove(index_next*sizeof[array_next]/L2_cache_line)
        L2.append(index_next*sizeof[array_next]/L2_cache_line)


      if index_next*sizeof[array_next]/cache_line not in temporal_cache_line:
       temporal_cache_line.append(index_next*sizeof[array_next]/cache_line)
      collect_cache_line.append(index_next*sizeof[array_next]/cache_line)
    else:
     loop = loop_next
     warp = warp_next
     access.append(len(collect))
     if array_next ==2:
      print(access_cache_line)
     collect = []
     collect.append(index_next)
     access_cache_line.append(1+(len(collect_cache_line)-1)*alfa)
     collect_cache_line = []
     if (rw_next ==0 ) and index_next*sizeof[array_next]/L1_cache_line in L1 and index_next*sizeof[array_next]/cache_line not in collect_cache_line and  math.fabs(len(L1)-L1.index(index_next*sizeof[array_next]/L1_cache_line)) <= L1_lines:
      L1_hit += 1
      L1.remove(index_next*sizeof[array_next]/L1_cache_line)
      L1.append(index_next*sizeof[array_next]/L1_cache_line)
     elif index_next*sizeof[array_next]/cache_line not in collect_cache_line:
      if rw_next == 0:
       if index_next*sizeof[array_next]/L1_cache_line in L1:
        L1.remove(index_next*sizeof[array_next]/L1_cache_line)
       L1.append(index_next*sizeof[array_next]/L1_cache_line)
      if index_next*sizeof[array_next]/L2_cache_line in L2 and \
         index_next*sizeof[array_next]/cache_line not in collect_cache_line and \
         math.fabs(len(L2)-L2.index(index_next*sizeof[array_next]/L2_cache_line)) <= L2_lines:
       L2_hit += 1
       L2.remove(index_next*sizeof[array_next]/L2_cache_line)
       L2.append(index_next*sizeof[array_next]/L2_cache_line)
      else:
       if index_next*sizeof[array_next]/L2_cache_line in L2:
        L2.remove(index_next*sizeof[array_next]/L2_cache_line)
       L2.append(index_next*sizeof[array_next]/L2_cache_line)
     if index_next*sizeof[array_next]/cache_line in temporal_cache_line and index_next*sizeof[array_next]/cache_line not in collect_cache_line:
      temporal_hit += 1
     collect_cache_line.append(index_next*sizeof[array_next]/cache_line)
     if index_next*sizeof[array_next]/cache_line not in temporal_cache_line:
      temporal_cache_line.append(index_next*sizeof[array_next]/cache_line)
   else:
   
    access.append(len(collect))
    collect = []
    collect.append(index_next)
 
    access_cache_line.append(1+(len(collect_cache_line)-1)*alfa)
    collect_cache_line = []
    if (rw_next == 0) and index_next*sizeof[array_next]/L1_cache_line in L1 and index_next*sizeof[array_next]/cache_line not in collect_cache_line and  math.fabs(len(L1)-L1.index(index_next*sizeof[array_next]/L1_cache_line)) <= L1_lines:
     L1_hit += 1
     L1.remove(index_next*sizeof[array_next]/L1_cache_line)
     L1.append(index_next*sizeof[array_next]/L1_cache_line)
    elif index_next*sizeof[array_next]/cache_line not in collect_cache_line:
     if rw_next == 0:
      if index_next*sizeof[array_next]/L1_cache_line in L1:
       L1.remove(index_next*sizeof[array_next]/L1_cache_line)
      L1.append(index_next*sizeof[array_next]/L1_cache_line)
     if index_next*sizeof[array_next]/L2_cache_line in L2 and \
        index_next*sizeof[array_next]/cache_line not in collect_cache_line and \
        math.fabs(len(L2)-L2.index(index_next*sizeof[array_next]/L2_cache_line)) <= L2_lines:
      L2_hit += 1
      L2.remove(index_next*sizeof[array_next]/L2_cache_line)
      L2.append(index_next*sizeof[array_next]/L2_cache_line)
     else:
      if index_next*sizeof[array_next]/L2_cache_line in L2:
       L2.remove(index_next*sizeof[array_next]/L2_cache_line)
      L2.append(index_next*sizeof[array_next]/L2_cache_line)
    if index_next*sizeof[array_next]/cache_line in temporal_cache_line and index_next*sizeof[array_next]/cache_line not in collect_cache_line:
     temporal_hit += 1
    collect_cache_line.append(index_next*sizeof[array_next]/cache_line)
    if index_next*sizeof[array_next]/cache_line not in temporal_cache_line:
     temporal_cache_line.append(index_next*sizeof[array_next]/cache_line)
    exp = exp_next
    loop = loop_next
    warp = warp_next
  else:
   access.append(len(collect))
   collect = []
   collect.append(index_next)
   access_cache_line.append(1+(len(collect_cache_line)-1)*alfa)
   collect_cache_line = []
   if (rw_next == 0) and index_next*sizeof[array_next]/L1_cache_line in L1 and index_next*sizeof[array_next]/cache_line not in collect_cache_line and math.fabs(len(L1)-L1.index(index_next*sizeof[array_next]/L1_cache_line)) <= L1_lines:
    L1_hit += 1
    L1.remove(index_next*sizeof[array_next]/L1_cache_line)
    L1.append(index_next*sizeof[array_next]/L1_cache_line)
   elif index_next*sizeof[array_next]/cache_line not in collect_cache_line:
    if rw_next == 0:
     if index_next*sizeof[array_next]/L1_cache_line in L1:
      L1.remove(index_next*sizeof[array_next]/L1_cache_line)
     L1.append(index_next*sizeof[array_next]/L1_cache_line)
    if index_next*sizeof[array_next]/L2_cache_line in L2 and index_next*sizeof[array_next]/cache_line not in collect_cache_line and math.fabs(len(L2)-L2.index(index_next*sizeof[array_next]/L2_cache_line)) <= L2_lines:
     L2_hit += 1
     L2.remove(index_next*sizeof[array_next]/L2_cache_line)
     L2.append(index_next*sizeof[array_next]/L2_cache_line)
    else:
     if index_next*sizeof[array_next]/L2_cache_line in L2:
      L2.remove(index_next*sizeof[array_next]/L2_cache_line)
     L2.append(index_next*sizeof[array_next]/L2_cache_line)
     
   
   if index_next*sizeof[array_next]/cache_line in temporal_cache_line and index_next*sizeof[array_next]/cache_line not in collect_cache_line:
    temporal_hit += 1
   collect_cache_line.append(index_next*sizeof[array_next]/cache_line)
   if index_next*sizeof[array_next]/cache_line not in temporal_cache_line:
    temporal_cache_line.append(index_next*sizeof[array_next]/cache_line)
   loop = loop_next
   exp = exp_next
   warp = warp_next
   rw = rw_next
 else: 
  access.append(len(collect))
  access_cache_line.append(len(collect_cache_line))
  for i in access:
   total += i
  print("Array "+str(array)+" put in constant memory has "+str(total)+ " latency")
  for i in access_cache_line:
   total_cache_line += i
  print("Array "+str(array)+" put in global memory has "+str(total_cache_line)+ " cold latency!")
  print("Array "+str(array)+" put in global memory has "+str(temporal_hit)+" temporal hits")
  print("Array "+str(array)+" put in global memory has "+str(L1_hit)+" L1 hits")
  print("Array "+str(array)+" put in global memory has "+str(L2_hit)+" L2 hits")
  array = array_next
  access = []
  temporal_hit = 0
  temporal_cache_line = []
  L1 = []
  L2 = []
  L1_hit = 0
  L2_hit = 0

  access_cache_line = []
  collect_cache_line=[]
  collect = []
  collect.append(index_next)
  collect_cache_line.append(index_next*sizeof[array_next]/cache_line)
  temporal_cache_line.append(index_next*sizeof[array_next]/cache_line)
  L1.append(index_next*sizeof[array_next]/L1_cache_line)
  L2.append(index_next*sizeof[array_next]/L2_cache_line)
  exp = exp_next
  loop = loop_next
  warp = warp_next
  rw = rw_next
  total = 0
  total_cache_line=0

access.append(len(collect))
access_cache_line.append(1+(len(collect_cache_line)-1)*alfa)
for i in access:
 total += i
for i in access_cache_line:
 total_cache_line += i

print("Array "+str(array_next)+" put in global memory has "+str(total)+ " latency")
print("Array "+str(array_next)+" put in global memory has "+str(total_cache_line)+ " cold latency")
print("Array "+str(array_next)+" put in global memory has "+str(temporal_hit)+ " temporal hits ")
print("Array "+str(array)+" put in global memory has "+str(L1_hit)+" L1 hits")
print("Array "+str(array)+" put in global memory has "+str(L2_hit)+" L2 hits")


print("###########################")
print("          Texture  Memory   1D              ")
print("###########################")
x=0
array = int(stride[x][0])
array_next = array
rw = int(stride[x][1])
exp = int(stride[x][2])
loop = int(stride[x][3])
index = int(stride[x][5])
warp = int(stride[x][4])
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
temporal_cache_line = []
temporal_hit = 0
while x<len(stride):
 array_next = int(stride[x][0])
 rw_next = int(stride[x][1])
 exp_next = int(stride[x][2])
 loop_next = int(stride[x][3])
 warp_next = int(stride[x][4])
 index_next = int(stride[x][5])
 x = x + 1
 if warp_next >=32:
  continue

 if (array == array_next):
  if(rw_next == 0):
   if (exp == exp_next):

    if (loop == loop_next):
     if index_next not in collect:
      collect.append(index_next)
      index = index_next
     if index_next*sizeof[array_next]/cache_line in temporal_cache_line and index_next*sizeof[array_next]/cache_line not in collect_cache_line:
      temporal_hit += 1
     if index_next*sizeof[array_next]/cache_line not in temporal_cache_line:
      temporal_cache_line.append(index_next*sizeof[array_next]/cache_line)
     if index_next*sizeof[array_next]/cache_line not in collect_cache_line:
      collect_cache_line.append(index_next*sizeof[array_next]/cache_line)
    else:
     loop = loop_next
     access.append(len(collect))
     collect = []
     collect.append(index_next)
     access_cache_line.append(1+(len(collect_cache_line)-1)*0.2)
     collect_cache_line = []
     if index_next*sizeof[array_next]/cache_line in temporal_cache_line and index_next*sizeof[array_next]/cache_line not in collect_cache_line:
      temporal_hit += 1
     collect_cache_line.append(index_next*sizeof[array_next]/cache_line)
     if index_next*sizeof[array_next]/cache_line not in temporal_cache_line:
      temporal_cache_line.append(index_next*sizeof[array_next]/cache_line)
   else:

    access.append(len(collect))
    collect = []
    collect.append(index_next)
    access_cache_line.append(1+(len(collect_cache_line)-1)*0.2)
    collect_cache_line = []
    if index_next*sizeof[array_next]/cache_line in temporal_cache_line and index_next*sizeof[array_next]/cache_line not in collect_cache_line:
     temporal_hit += 1
    collect_cache_line.append(index_next*sizeof[array_next]/cache_line)
    if index_next*sizeof[array_next]/cache_line not in temporal_cache_line:
     temporal_cache_line.append(index_next*sizeof[array_next]/cache_line)
    exp = exp_next
    loop = loop_next
  else:
   access = []
   access_cache_line = []
   collect_cache_line=[]
   collect = []
   temporal_hit = 0
   temporal_cache_line = []
   loop = loop_next
   exp = exp_next
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
   print("Array "+str(array)+" put in texture memory 1D  has "+str(temporal_hit)+" temporal hits")
  array = array_next
 # rw = rw_next
  access = []
  access_cache_line = []
  collect_cache_line=[]
  collect = []
  collect.append(index_next)
  temporal_hit = 0
  temporal_cache_line = []
  collect_cache_line.append(index_next*sizeof[array_next]/cache_line)
  temporal_cache_line.append(index_next*sizeof[array_next]/cache_line)
  exp = exp_next
  loop = loop_next
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
 print("Array "+str(array)+" put in texture memory 1D  has "+str(temporal_hit)+" temporal hits")


print("###########################")
print("          Texture  Memory   2D              ")
print("###########################")
x=0
array = int(stride[x][0])
array_next = array
rw = int(stride[x][1])
exp = int(stride[x][2])
loop = int(stride[x][3])
index = int(stride[x][5])
warp = int(stride[x][4])
print1 = 0
cache_line = 128
add = 0
#array_total=[]
flag = 0
total = 0
total_cache_line=0
access = []
access_cache_line = []
collect = []
collect_cache_line = []
collect_array = []
temporal_hit = 0
temporal_cache = []
def kong(n):
 kong_set = []
 for i in range(0,(block_X[n] + 3)/4):
  xi = []
  for j in range(0,(block_Y[n]+3)/4):
   xi.append(0)
  kong_set.append(xi)
 return kong_set
while x<len(stride):
 array_next = int(stride[x][0])
 rw_next = int(stride[x][1])
 exp_next = int(stride[x][2])
 loop_next = int(stride[x][3])
 warp_next = int(stride[x][4])
 index_next = int(stride[x][5])
 x = x + 1
 if warp_next >=32:
  continue
 if (x==1):
  collect_array = kong(0)
  temporal_cache = kong(0)

 if (array == array_next):
  if(rw_next == 0):
   if (exp == exp_next):

    if (loop == loop_next):
     if index_next not in collect:
      collect.append(index_next)
      index = index_next
     #if index_next*sizeof[array_next]/cache_line not in collect_cache_line:
     # collect_cache_line.append(index_next*sizeof[array_next]/cache_line)
     if (temporal_cache[(index_next%block_X[array])/4][(index_next/block_X[array])/4]==1) \
        and (collect_array[(index_next%block_X[array])/4][(index_next/block_X[array])/4]!=1):
      temporal_hit += 1
     temporal_cache[(index_next%block_X[array])/4][(index_next/block_X[array])/4]=1
     collect_array[(index_next%block_X[array])/4][(index_next/block_X[array])/4] = 1
     #if(array ==1):
      #print(str(index_next)+" "+str((index_next%block_X[array])/4)+" "+str((index_next/block_X[array])/4))
    else:
     loop = loop_next
     access.append(len(collect))
     collect = []
     add = 0
     collect.append(index_next)
     for xi in range(0,(block_X[array]+3)/4):
      for yi in range(0,(block_Y[array]+3)/4):
       if collect_array[xi][yi] == 1:
        add += 1
     access_cache_line.append(1+(add-1)*alfa)
     collect_array = kong(array_next)
     if temporal_cache[(index_next%block_X[array])/4][(index_next/block_X[array])/4]==1 and collect_array[(index_next%block_X[array])/4][(index_next/block_X[array])/4] != 1:
      temporal_hit += 1
     temporal_cache[(index_next%block_X[array])/4][(index_next/block_X[array])/4]=1
     collect_array[(index_next%block_X[array_next])/4][(index_next/block_X[array_next])/4] = 1
   else:

    access.append(len(collect))
    collect = []
    collect.append(index_next)
    add = 0
    for xi in range(0,(block_X[array]+3)/4):
     for yi in range(0,(block_Y[array]+3)/4):
      if collect_array[xi][yi] == 1:
       add += 1
    access_cache_line.append(1+(add-1)*alfa)
    collect_array = kong(array_next)
    if temporal_cache[(index_next%block_X[array])/4][(index_next/block_X[array])/4]==1 and collect_array[(index_next%block_X[array])/4][(index_next/block_X[array])/4] != 1:
     temporal_hit += 1
    temporal_cache[(index_next%block_X[array])/4][(index_next/block_X[array])/4]=1
    #print(str(x)+" index "+str(index_next)+" "+str((index_next%block_X[array_next])/4)+" "+str((index_next/block_X[array_next])/4))
    collect_array[(index_next%block_X[array_next])/4][(index_next/block_X[array_next])/4] = 1
    exp = exp_next
    loop = loop_next
  else:
   access = []
   access_cache_line = []
   collect = []
   collect_array=kong(array_next)
   temporal_hit = 0
   temporal_cache = kong(array_next)
   loop = loop_next
   exp = exp_next
   total = 99999999
   if(print1 == 0):
    print("array "+str(array)+" can only be put in shared memory or global memory")
    print1 += 1
 else:

  access.append(len(collect))
  add = 0
  for xi in range(0,(block_X[array]+3)/4):
   for yi in range(0,(block_Y[array]+3)/4):
    if collect_array[xi][yi] == 1:
     add += 1
  access_cache_line.append(1+(add-1)*alfa)
 # print(access_cache_line)
  for i in access:
   total += i
  if dimension[array] == 2:
   print("Array "+str(array)+" put in texture memory 2D has "+str(total)+ " latency")
  for i in access_cache_line:
   total_cache_line += i
  if dimension[array] == 2:
   print("Array "+str(array)+" put in texture memory 2D has "+str(total_cache_line)+ " cold latency!")
   print("Array "+str(array)+" put in texture memory 2D has "+str(temporal_hit)+ " temporal hits!")
  # rw = rw_next
  access = []
  access_cache_line = []
  collect = []
  collect.append(index_next)
  collect_array = kong(array_next) 
  temporal_hit = 0
  temporal_cache = kong(array_next)
  temporal_cache[(index_next%block_X[array_next])/4][(index_next/block_X[array_next])/4] = 1
  collect_array[(index_next%block_X[array_next])/4][(index_next/block_X[array_next])/4] = 1
  exp = exp_next
  loop = loop_next
  total = 0
  total_cache_line=0
  array=array_next
access.append(len(collect))
add = 0
for xi in range(0,(block_X[array_next]+3)/4):
 for yi in range(0,(block_Y[array_next]+3)/4):
  if collect_array[xi][yi] == 1:
   add += 1
access_cache_line.append(1+(add-1)*alfa)
for i in access:
 total += i
for i in access_cache_line:
 total_cache_line += i
if dimension[array_next] == 2:
 print("Array "+str(array_next)+" put in texture memory has "+str(total)+ " latency")
if dimension[array_next] == 2:
 print("Array "+str(array_next)+" put in texture memory has "+str(total_cache_line)+ " cold latency")
 print("Array "+str(array)+" put in texture memory 2D has "+str(temporal_hit)+ " temporal hits!")











print("###########################")
print("          Shared  Memory                 ")
print("###########################")
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
   if i*sizeof[array]/cache_line not in collect_cache_line:
    collect_cache_line.append(i*sizeof[array]/cache_line)
  total_cache_line = len(collect_cache_line)
  print("Array "+str(array)+" put in shared memory has "+str(total)+ " latency")
  print("Array "+str(array)+" put in shared memory has "+str(total_cache_line)+ " cold latency")
  if len(collect)>6 * 1024/ sizeof[array]:
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
collect_total.append(collect)
collect_cache_line = []
total = len(collect)
for i in collect:
 if i*sizeof[array]/cache_line not in collect_cache_line:
  collect_cache_line.append(i*sizeof[array]/cache_line)
total_cache_line = len(collect_cache_line)
print("Array "+str(array)+" put in shared memory has "+str(total)+ " latency")
print("Array "+str(array)+" put in shared memory has "+str(total_cache_line)+ " cold latency")
if len(collect)>6 * 1024/ sizeof[array]:
 total_2 = 9999999
 print("Array "+str(array)+" can not be put in shared memory!")
else:
 total_2 = x + 1 - flag - total
 print(x)
 print(flag)
 print("Array "+str(array)+" accessed in shared memory has "+str(total_2)+ " shared latency")


#################################
#         Bank Conflicts
#################################
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
total_max = 0
collect_cache_line = []
temporal_cache_line = []
temporal_hit = 0
shared_index = {}
for i in range(0,len(collect_total[array])):
 shared_index[i] = 0
new_index = shared_index.copy()
bank = {}
for i in range(0,32):
 bank[i]=0
new_bank = bank.copy()
while x<len(stride):
 array_next = int(stride[x][0])
 rw_next = int(stride[x][1])
 exp_next = int(stride[x][2])
 loop_next = int(stride[x][3])
 warp_next = int(stride[x][4])
 index_next = int(stride[x][5])
 x = x + 1
 if warp_next >=32:
  continue
 if (array == array_next):
  if(rw_next == rw):
   if (exp == exp_next):

    if (loop == loop_next):
     new_index[collect_total[array_next].index(index_next)] += 1
    else:
     for i in range(0,len(collect_total[array])):
      if new_index[i]!=0:
       new_bank[i%32]+=1
     max = -1
     for i in range(0,32):
      if new_bank[i]>=max:
       max = new_bank[i]
     total_max += max 
     shared_index = {}
     for i in range(0,len(collect_total[array_next])):
      shared_index[i] = 0
     new_index = shared_index.copy()
     new_bank = bank.copy()
     new_index[collect_total[array].index(index_next)] += 1
     loop = loop_next
   else:

    for i in range(0,len(collect_total[array])):
     if new_index[i]!=0:
      new_bank[i%32]+=1
    max = -1
    for i in range(0,32):
     if new_bank[i]>=max:
      max = new_bank[i]
    total_max += max 
    shared_index = {}
    for i in range(0,len(collect_total[array_next])):
     shared_index[i] = 0
    new_index = shared_index.copy()
    new_bank = bank.copy()
    new_index[collect_total[array].index(index_next)] += 1
    exp = exp_next
    loop = loop_next
  else:
   for i in range(0,len(collect_total[array])):
    if new_index[i]!=0:
     new_bank[i%32]+=1
   max = -1
   for i in range(0,32):
    if new_bank[i]>=max:
     max = new_bank[i]
   total_max += max 
   shared_index = {}
   for i in range(0,len(collect_total[array_next])):
    shared_index[i] = 0
   new_index = shared_index.copy()
   new_bank = bank.copy()
   new_index[collect_total[array].index(index_next)] += 1
   loop = loop_next
   exp = exp_next
   rw = rw_next
   if(print1 == 0):
    print("array "+str(array)+" can only be put in shared memory or global memory")
    print1 += 1
 else:
  rw = rw_next
  for i in range(0,len(collect_total[array])):
   if new_index[i]!=0:
    new_bank[i%32]+=1
  max = -1
  for i in range(0,32):
   if new_bank[i]>=max:
    max = new_bank[i]
  total_max += max 
  print("Array "+str(array)+" has "+str(total_max)+ " shared latency")
  shared_index = {}
  for i in range(0,len(collect_total[array_next])):
   shared_index[i] = 0
  new_index = shared_index.copy()
  new_bank = bank.copy()
  new_index[collect_total[array].index(index_next)] += 1
  array = array_next
  exp = exp_next
  loop = loop_next
  total_max = 0
  
for i in range(0,len(collect_total[array_next])):
 if new_index[i]!=0:
  new_bank[i%32]+=1
max = -1
for i in range(0,32):
 if new_bank[i]>=max:
  max = new_bank[i]
total_max += max 
print("Array "+str(array)+" has "+str(total_max)+ " shared latency")
