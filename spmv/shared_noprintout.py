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
start = time.time()
alfa = 1
dimension =[]# [2,2,2]
sizeof = []#[4, 4, 4]
block_X = []#[3072,3072,3072]
block_Y = []#[256,256,256]
array_size = []
stride = []
f = open("ldshared.txt",'a')
out = open("output.txt",'a')
out.write("Shared: ")
#time.sleep(2)
for line in open(sys.argv[4],'r'):
 thread = line.strip()
 if thread[0].isdigit():
  thread = thread.split()
  for xx in range(0,len(thread)):
   thread[xx] = int(thread[xx])
  stride.append(thread)
 elif  thread[0] == '[':
  while thread[0]!= ':':
   thread = thread[1:]
  thread = thread[1:]
  thread = thread.split()
  for xx in range(0,len(thread)):
   thread[xx] = int(thread[xx])
  stride.append(thread)
 else: 
  th_save = thread
  thread = thread.split()
  for i in range(1,len(thread)):
   thread[i] = int(thread[i])
  if thread[0] == "dimension":
   dimension = thread[1:]
   f.write(th_save+"\n")
  elif thread[0]=="sizeof":
   sizeof = thread[1:]
   f.write(th_save+"\n")
  elif thread[0] =="block_X":
   block_X = thread[1:]
   f.write(th_save+"\n")
  elif thread[0] == "block_Y":
   block_Y = thread[1:]
   f.write(th_save+"\n")
  elif thread[0] == "array_size":
   f.write(th_save+"\n")
   array_size = thread[1:]
  else:
   continue
stride.sort(
key = lambda l:(l[0],l[1],l[2],l[3],l[4])
)
end3 = time.time()
print end3-start, "shared read"
print("###########################")
print("          Shared  Memory                 ")
print("###########################")
fconf = open("configure.txt",'r')
global_info = []
texture_info = []
for line in fconf:
 s = line.strip()
 s= s.split()
 if s[0].upper() == "GLOBAL":
  global_info = s
 elif s[0].upper()=="TEXTURE":
  texture_info = s
s = global_info
print(global_info)
global_size = int(s[1])
glo_lat = int(s[2])
L2_size = int(s[3])
L2_cache_line = int(s[4])
L2_lat = int(s[5])
L1_size = int(s[6])
L1_cache_line = int(s[7])
L1_lat = int(s[8])
if L2_cache_line < L1_cache_line:
 L2_cache_line = L1_cache_line
if L2_size == 0:
 L2_cache_line = sizeof[0]
if L1_size == 0:
 L1_cache_line = sizeof[0]
 L1_cache_line = L2_cache_line
#L1_cache_line = 128
#L1_size = 16*1024
#L2_cache_line = 32
#L2_size = 768*1024
if L2_cache_line < L1_cache_line:
 L2_cache_line = L1_cache_line
L1_lines = L1_size/L1_cache_line
L2_lines = L2_size/L2_cache_line
x=0
printout = "- global "
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
rw_flag = 0
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
  if(rw_next == 1):
   rw_flag = 1
  if index_next not in collect:
   collect.append(index_next)
  
  #if index_next*sizeof[array_next]/cache_line not in collect_cache_line:
  # collect_cache_line.append(index_next*sizeof[array_next]/cache_line)
 else:
  collect.sort()
  for i in collect:
    
   f.write(str(array)+" "+str(rw_flag)+" 0 0 0 "+str(i)+"\n")#str(collect.index(i))+" "+str(i)+"\n")
  #f.close()
  #s = texture_info
  #exe_command = "./texture.py "+s[1]+" "+s[2]+" "+s[3]+" "+s[4]+" "+s[5]+" "+s[6]+" "+s[7]+" "+s[8]+" "+s[9]+" ldshared.txt"
  #os.system(exe_command)
  #os.system("rm ldshared.txt")
  collect_total.append(collect)
  collect_cache_line = []
  rw_flag = 0
  total = len(collect)
  for i in collect:
   if i*sizeof[array]/cache_line  in L1 and i*sizeof[array]/cache_line not in collect_cache_line and math.fabs(len(L1)-L1.index(i*sizeof[array]/L1_cache_line)) <= L1_lines:
    #print(i)
    #print(L1)
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
  out.write(str(len(collect))+" ")
  if len(collect)>6 * 1024/ sizeof[array]:
   total_2 = 99999999
   total_cache_line = 99999999
  else: 
   total_2 = x - flag - total
  printout = printout +str(total_cache_line)+" "+str(L1_hit)+" "+str(L2_hit)+" "
  
  print("Array "+str(array)+" accessed in  shared memory has "+str(total_2)+ " shared latency")
  print("Array "+str(array)+" accessed in  shared memory has "+str(L1_hit)+ " L1 hits")
  print("Array "+str(array)+" accessed in  shared memory has "+str(L2_hit)+ " L2 hits")
  flag = x
  total = 0
  collect = []
  clolect_cache_line = []
  L1_hit = 0
  L2_hit = 0
  L1 = []
  L2 = []
  array = array_next
  collect.append(index_next)
  collect_cache_line.append(index_next*sizeof[array_next]/cache_line)
  #L1.append(index_next*sizeof[array_next]/cache_line)
  #L2.append(index_next*sizeof[array_next]/L2_cache_line)
  """f = open("ldshared.txt",'a')
  for line in open(sys.argv[4],'r'):
   thread = line.strip()
   if thread[0].isdigit():
    thread = thread.split()
    for xx in range(0,len(thread)):
     thread[xx] = int(thread[xx])
   elif  thread[0] == '[':
    while thread[0]!= ':':
     thread = thread[1:]
    thread = thread[1:]
    thread = thread.split()
    for xx in range(0,len(thread)):
     thread[xx] = int(thread[x])
   else:
    th_save = thread
    thread = thread.split()
    for i in range(1,len(thread)):
     thread[i] = int(thread[i])
    if thread[0] == "dimension":
     dimension = thread[1:]
     f.write(th_save+"\n")
    elif thread[0]=="sizeof":
     sizeof = thread[1:]
     f.write(th_save+"\n")
    elif thread[0] =="block_X":
     block_X = thread[1:]
     f.write(th_save+"\n")
    elif thread[0] == "block_Y":
     block_Y = thread[1:]
     f.write(th_save+"\n")
    elif thread[0] == "array_size":
     f.write(th_save+"\n")
     array_size = thread[1:]
    else:
     continue"""
collect.sort()

for i in collect:
 f.write(str(array_next)+" "+str(rw_flag)+" 0 0 0"+" "+str(i)+"\n")#str(collect.index(i))+" "+str(i)+"\n")
f.close()
s = texture_info
#exe_command = "./texture.py "+s[1]+" "+s[2]+" "+s[3]+" "+s[4]+" "+s[5]+" "+s[6]+" "+s[7]+" "+s[8]+" "+s[9]+" ldshared.txt"
#os.system(exe_command)
collect_total.append(collect)
collect_cache_line = []
array = array_next
total = len(collect)
for i in collect:
 if i*sizeof[array_next]/cache_line  in L1 and i*sizeof[array_next]/cache_line not in collect_cache_line and math.fabs(len(L1)-L1.index(i*sizeof[array_next]/L1_cache_line)) <= L1_lines:
  L1_hit += 1
  print(array_next)
  print(L1)
  L1.remove(i*sizeof[array_next]/cache_line)
  L1.append(i*sizeof[array_next]/cache_line)
 elif i*sizeof[array_next]/cache_line not in collect_cache_line:
  if i*sizeof[array_next]/cache_line in L1:
   L1.remove(i*sizeof[array_next]/cache_line)
  L1.append(i*sizeof[array_next]/cache_line)
  if i*sizeof[array]/L2_cache_line  in L2 and i*sizeof[array]/cache_line not in collect_cache_line and math.fabs(len(L2)-L2.index(i*sizeof[array]/L2_cache_line)) <= L2_lines:
   L2_hit += 1
   L2.remove(i*sizeof[array_next]/L2_cache_line)
   L2.append(i*sizeof[array_next]/L2_cache_line)
  elif i*sizeof[array]/cache_line not in collect_cache_line:
   if i*sizeof[array]/L2_cache_line  in L2:
    L2.remove(i*sizeof[array]/L2_cache_line)
   L2.append(i*sizeof[array]/L2_cache_line)
 if i*sizeof[array]/cache_line not in collect_cache_line:
  collect_cache_line.append(i*sizeof[array]/cache_line)
total_cache_line = len(collect_cache_line)
print("Array "+str(array)+" put in shared memory has "+str(total)+ " latency")
print("Array "+str(array)+" put in shared memory has "+str(total_cache_line)+ " cold latency")
out.write(str(len(collect))+"\n")
if len(collect)>6 * 1024/ sizeof[array]:
 total_2 = 99999999
 total_cache_line = 99999999
 print("Array "+str(array)+" can not be put in shared memory!")
else:
 total_2 = x + 1 - flag - total
 print(x)
 print(flag)
 print("Array "+str(array)+" accessed in shared memory has "+str(total_2)+ " shared latency")
 print("Array "+str(array)+" accessed in  shared memory has "+str(L1_hit)+ " L1 hits")
 print("Array "+str(array)+" accessed in  shared memory has "+str(L2_hit)+ " L2 hits")

printout = printout + str(total_cache_line)+" "+str(L1_hit)+" "+str(L2_hit)+"\n- "
out.write(printout)
out.close()
end1= time.time()
print end1-start, "shared process including global"
if dimension[0] == 2:
 exe_command = "./../scripts/1Dtexture_noprint.py "+s[1]+" "+" "+s[3]+" "+s[4]+" "+s[5]+" "+s[6]+" "+s[7]+" "+s[8]+" "+s[9]+" ldshared.txt"
 os.system(exe_command)
 out = open("output.txt",'a')
 out.write("- ")
 out.close()
 exe_command = "./../scripts/2Dtexture_noprintout.py "+s[1]+" "+s[2]+" "+s[3]+" "+s[4]+" "+s[5]+" "+s[6]+" "+s[7]+" "+s[8]+" "+s[9]+" "+str(sys.argv[4])#" ldshared.txt"
 os.system(exe_command)
else:
 exe_command = "./../scripts/1Dtexture_noprint.py "+s[1]+" "+s[3]+" "+s[4]+" "+s[5]+" "+s[6]+" "+s[7]+" "+s[8]+" "+s[9]+" ldshared.txt"
 os.system(exe_command)
 printout = "- texture2D"
 for x in sizeof:
  printout += " 99999999 0 0"
 printout +="\n"
 out = open("output.txt",'a')
 out.write(printout)
 out.close()
#################################
#         Bank Conflicts
#################################
start = time.time()
out = open("output.txt",'a')
printout = "shared "
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
 #if warp_next >=32:
 # continue
 if (array == array_next):
  if(rw_next == rw):
   if (exp == exp_next):

    if (loop == loop_next):
     if (warp/32 == warp_next/32):
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
      warp = warp_next
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
     warp = warp_next
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
    warp = warp_next
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
   warp = warp_next
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
  printout += str(total_max)+" "  
  shared_index = {}
  for i in range(0,len(collect_total[array_next])):
   shared_index[i] = 0
  new_index = shared_index.copy()
  new_bank = bank.copy()
  new_index[collect_total[array_next].index(index_next)] += 1
  array = array_next
  exp = exp_next
  loop = loop_next
  warp = warp_next
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
printout += str(total_max)+"\n"
out.write(printout)
end =time.time()
print end-start
