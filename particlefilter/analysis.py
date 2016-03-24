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
if len(sys.argv)!=3:
 print("usage: ./analysis.py *.txt dimension")
threads=16
print(sys.argv[1])
f=open(sys.argv[1],'r')
loca_time=[]
for line in f:
 temp=[]
 line=line.strip()
 line=re.split(',|;',line)
 for i in range(0,len(line)):
  temp.append(line[i])
 loca_time.append(temp)
###################################################
#constant memory analysis
total=0
total_priority=0
for i in range(0,threads):
 count_i=0
 for j in range(0,threads):
  if i!=j or i ==j:
   count = 0
   priority=0
   for loca_i in range(0,(len(loca_time[i])-1)/2):
    for loca_j in range(0,(len(loca_time[j])-1)/2):
     if loca_time[i][2*loca_i]==loca_time[j][2*loca_j]:
      priority += int(loca_time[i][2*loca_i+1])
      count = count + 1
      break
   if ((len(loca_time[i])-1)/2)!=0 and (float(count) / ((len(loca_time[i])-1)/2) > 0.8):
    total_priority += priority
    count_i = count_i + 1
 total=total+count_i/threads
if total/threads>=0.5:
 print(sys.argv[1]+" should be put in constant memory!\n If the size is larger than constant memory, please put it in texture memory!")
 print("total priority = memory access times: "+str(total_priority/threads))

####################################################
#texture memory  2 dimensions
if sys.argv[2]=='2':
 total=0
 rate={}
 max_rate=1
 for i in range(0,threads):
 #count=int(loca_time[i+4][0])-int(loca_time[i][0])
  total += ((len(loca_time[i])-1)/2)
  for loca_i in range(0,(len(loca_time[i])-1)/2):
   if (i<(threads-4)) and (2*loca_i < len(loca_time[i+4])) :
    if (int(loca_time[i+4][loca_i*2])-int(loca_time[i][loca_i*2])) not in rate.keys():
     rate[int(loca_time[i+4][loca_i*2])-int(loca_time[i][loca_i*2])]=1
    else:
     rate[int(loca_time[i+4][loca_i*2])-int(loca_time[i][loca_i*2])]+=1
   if (i>=(threads-4)) and (2*loca_i < len(loca_time[i-4])):
    if  (int(loca_time[i][loca_i*2])-int(loca_time[i-4][loca_i*2])) not in rate.keys():
     rate[int(loca_time[i][loca_i*2])-int(loca_time[i-4][loca_i*2])]=1
    else:
     rate[int(loca_time[i][loca_i*2])-int(loca_time[i-4][loca_i*2])]+=1
 for j in rate.keys():
  if max_rate<rate[j]:
   count=j
   max_rate=rate[j]
 if max_rate / total >0.8 and sys.argv[2]=='2':
  print("choose column = "+str(count))
  print(sys.argv[1]+" should be put in texture memory!")
  priority=0
  for i in range(0,threads):
 #count=int(loca_time[i+4][0])-int(loca_time[i][0])
   for loca_i in range(0,(len(loca_time[i])-1)/2):
    if (i<(threads-4)) and (2*loca_i < len(loca_time[i+4])) : 
     if loca_time[i][loca_i*2]!='' and (int(loca_time[i+4][loca_i*2])-int(loca_time[i][loca_i*2])==count):
      priority += int(loca_time[i][2*loca_i+1])
    if (i>=(threads-4)) and (2*loca_i < len(loca_time[i-4])):
     if loca_time[i][loca_i*2]!='' and  (int(loca_time[i][loca_i*2])-int(loca_time[i-4][loca_i*2])==count):
      priority += int(loca_time[i][2*loca_i+1])
  print("total priority = memory access times: "+str(priority))

################################################################
#shared memory 
rate={}
count2=0
total_priority=0
for i in range(0,threads):
 for loca_i in range(0,(len(loca_time[i])-1)/2):
  for j in range(0,threads):
   for loca_j in range(0,(len(loca_time[j])-1)/2):
    if i!=j and loca_time[i][2*loca_i]==loca_time[j][2*loca_j]:
     if  int(loca_time[i][2*loca_i]) not in rate.keys():
      rate[int(loca_time[i][2*loca_i])]=1
     else :
      rate[int(loca_time[i][2*loca_i])] +=1
 count=0
 priority=0
 for loca_i in range(0,(len(loca_time[i])-1)/2):    
  if  (int(loca_time[i][2*loca_i]) in rate.keys() or int(loca_time[i][2*loca_i+1])>=2):
   count +=1
   if (int(loca_time[i][2*loca_i]) in rate.keys()):
    priority += rate[int(loca_time[i][2*loca_i])]*int(loca_time[i][2*loca_i+1])
   else:
    priority += int(loca_time[i][2*loca_i+1])
 if (len(loca_time[i])-1)!=0 and count/((len(loca_time[i])-1)/2)>0.5:
  count2 +=1
  total_priority += priority
print(count2)
if count2/threads>0.8:
 print(sys.argv[1]+" should be put in shared memory when size allowed!")
 print("total priority = memory access times: "+str(total_priority))
