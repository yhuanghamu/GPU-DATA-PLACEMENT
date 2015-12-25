#!/usr/bin/python

"""
usage: ./bb.py *.txt dimension 
"""

import sys
import os
import string

record = 0
global_min = 9999999999
Mem =["constant","global","texture","texture","global","texture","texture"]
w = []
s = [] 
con_lat = []
glo_lat = []
tex_lat = []
dimension = []
sizeof = []
block_X = []
block_Y = []
array_size = []
L2 = {}
L1 = {}
contension = {}
global_size = 0
for line in open("configure.txt",'r'):
 l = line.strip()
 l = l.split()
 
 if l[0] == "constant":
  s.append(int(l[1]))
  con_lat.append(int(l[2]))
  con_lat.append(int(l[5]))
  con_lat.append(int(l[8]))
 elif l[0] == "global":
  s.append(int(l[1]))
  global_size = int(l[1])
  glo_lat.append(int(l[2]))
  glo_lat.append(int(l[5]))
  glo_lat.append(int(l[8]))
 elif l[0] == "texture":
  s.append(global_size)
  tex_lat.append(int(l[3]))
  tex_lat.append(int(l[6]))
  tex_lat.append(int(l[9]))
 elif l[0] == "shared":
  s.append(int(l[1]))
  sh_lat= int(l[3])
 elif l[0] == "-":
  for ll in range(2,len(l)):
   L2[l[ll]] = l[1]
   print(L2)
 elif l[0] == "--":
  for ll in range(2,len(l)):
   L1[l[ll]] = l[1]
print(L1)
print(L2)
#initialize contension = 0
for l in L2:
 contension[L2[l]] = 0
for l in L1:
 contension[L1[l]] = 0
print(contension)
for line in open(str(sys.argv[1]),'r'):
 l = line.strip()
 l = l.split()
 if l[0] == "dimension":
  dimension = l[1:]
 elif l[0] == "sizeof":
  sizeof = l[1:]
 elif l[0] == "block_X":
  block_X = l[1:]
 elif l[0] == "block_Y":
  block_Y = l[1:]
 elif l[0] == "array_size":
  array_size = l[1:]
 else:
  continue
for i in array_size:
 w.append(int(i))
shared_size = []
p = []
p_shared = []

for x in range(0,len(w)):
 p.append([])

for line in open("output.txt",'r'):
 l = line.strip()
 l = l.split()
 if l[0] == "constant":       #0
  for x in range(1,len(l)):
   l[x] = int(l[x])
  for x in range(0,len(l)/4):
   p[x].append(l[4*x+1:4*x+5])
 elif l[0] == "global":        #1
  for x in range(1,len(l)):
   l[x] = int(l[x])
  for x in range(0,len(l)/3):
   p[x].append(l[3*x+1:3*x+4])
 elif l[0] == "texture1D" or l[0] == "texture2D":  #2 /3
  for x in range(1,len(l)):
   l[x] = int(l[x])
  for x in range(0,len(l)/3):
   p[x].append(l[3*x+1:3*x+4])
 elif l[0] =="-":               #4 /5 /6
  for x in range(2,len(l)):
   l[x] = int(l[x])
  for x in range(0,(len(l)-1)/3):
   p[x].append(l[3*x+2:3*x+5])
 elif l[0] == "Shared:":
  for x in range(1,len(l)):
   shared_size.append(int(l[x]))
 elif l[0] == "shared":
  for x in range(1,len(l)):
   p_shared.append(int(l[x]))
  
print(shared_size) 
print(p_shared)
#w=[262144,3932160,3932160]
#p=[[32*300+480*100,25*500,25*480,25*500+30*512],[30*300+480*100,25*500,25*480,99999999],[99999999,4*500,99999999,9999999]]
#s=[64*1024, 10000000000, 100000000,6*1024]


def cal_lat(k,j,c,share,total_tem,conten):
 if j == 0:  #constant
  if p[k][j][0] == "99999999":
   return(999999999)
  else:
   latency = p[k][j][2]/conten[L1["L1_constant"]]*con_lat[2]+p[k][j][3]/conten[L2["L2_constant"]]*con_lat[1]+(p[k][j][0]-p[k][j][1])*con_lat[2] +(p[k][j][1]-p[k][j][2]/conten[L1["L1_constant"]]-p[k][j][3]/conten[L2["L2_constant"]])*con_lat[0]
   return latency
 if j == 1: #global
  if p[k][j][0] == "99999999":
   return(999999999)
  else: 
   latency = p[k][j][1]/conten[L1["L1_global"]]*glo_lat[2]+p[k][j][2]/conten[L2["L2_global"]]*glo_lat[1]+(p[k][j][0]-p[k][j][1]/conten[L1["L1_global"]]-p[k][j][2]/conten[L2["L2_global"]])*glo_lat[0]
   return latency  
 if j == 2 or j ==3:
  if p[k][j][0] == "99999999":
   return(999999999)
  else: 
   latency = p[k][j][1]/conten[L1["L1_texture"]]*tex_lat[2]+p[k][j][2]/conten[L2["L2_texture"]]*tex_lat[1]+(p[k][j][0]-p[k][j][1]/conten[L1["L1_texture"]]-p[k][j][2]/conten[L2["L2_texture"]])*tex_lat[0]
   return latency  
 if j == 4: #shared global
  if p[k][j][0] == "99999999":
   return(999999999)
  else:
   print(p_shared[k])
   latency = p[k][j][1]/conten[L1["L1_global"]]*glo_lat[2]+p[k][j][2]/conten[L2["L2_global"]]*glo_lat[1]+(p[k][j][0]-p[k][j][1]/conten[L1["L1_global"]]-p[k][j][2]/conten[L2["L2_global"]])*glo_lat[0] + p_shared[k]*sh_lat
   
   return latency
 if j == 5 or j ==6:
  if p[k][j][0] == "99999999":
   return(999999999)
  else: 
   latency = p[k][j][1]/conten[L1["L1_texture"]]*tex_lat[2]+p[k][j][2]/conten[L2["L2_texture"]]*tex_lat[1]+(p[k][j][0]-p[k][j][1]/conten[L1["L1_texture"]]-p[k][j][2]/conten[L2["L2_texture"]])*tex_lat[0]+p_shared[k]*sh_lat
   return latency
 
print(s)
print(w)
def first_j(k,j,c,share,total_tem,conten):
 global record
 global global_min
 total = total_tem
 if j<=3:
  if c[j] < w[k]:
   total = 999999999
   return (total, [-1])
  mini = 10000000000000000
  l2 = []
  conten[L2["L2_"+Mem[j]]] += 1
  conten[L1["L1_"+Mem[j]]] += 1
  total = cal_lat(k,j,c,share,total_tem,conten)
 #print (c[j])
# print ("j= "+str(j))
  c[j] = c[j] - w[k]
  if total > global_min:
   return (9999999999999,[-1])
  record += 1
  if k == (len(w)-1):
   global_min = total
   return (total,[j])

  for i in range(0,len(Mem)):
   c1 = []
   share1 = share
   conten1 = {}
   for ii in range(0,len(c)):
    c1.append(c[ii])
   
   for ii in conten.keys():
    conten1[ii]= conten[ii]
   (last_min,l_s) = first_j(k+1,i,c1,share1,total,conten1)
  
   if(mini >  last_min):
    mini = last_min 
    l2 = l_s
 #return (mini,l2) print("array "+ str(k+1)+" put in memory "+ str(l2))
  l3=[j]
  l3.extend(l2)
  return (mini,l3)
 else: #shared 

  if c[j-3] < w[k] or shared_size[k] > share:
   total = 999999999
   return (total, [-1])
  mini = 10000000000000000
  l2 = []
  conten[L2["L2_"+Mem[j-3]]] += 1
  conten[L1["L1_"+Mem[j-3]]] += 1
  total = cal_lat(k,j,c,share,total_tem,conten)
 #print (c[j])
# print ("j= "+str(j))
  c[j-3] = c[j-3] - w[k]
  share -= shared_size[k]
  if total > global_min:
   return (9999999999999,[-1])
  record += 1
  if k == (len(w)-1):
   global_min = total
   return (total,[j])
 #print(total)
  for i in range(0,len(Mem)):
   c1 = []
   share1 = share
   conten1 = {}
   for ii in range(0,len(c)):
    c1.append(c[ii])
   for ii in conten.keys():
    conten1[ii]= conten[ii]
   (last_min,l_s) = first_j(k+1,i,c1,share1,total,conten1)
  
   if(mini >  last_min):
    mini = last_min 
    l2 = l_s
 #return (mini,l2) print("array "+ str(k+1)+" put in memory "+ str(l2))
  l3=[j]
  l3.extend(l2)
  return (mini,l3)
min = 999999999999
ll=[]
shared_total = 6*1024
for j in range(0,len(Mem)):
 (lastmin,ls)=first_j(0,j,s,shared_total,0,contension)
 if (min > lastmin):
  min = lastmin
 
  ll = ls
print("total latency= "+str(min))
print(ll)
print(record)
