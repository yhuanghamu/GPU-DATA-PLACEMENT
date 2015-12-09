#!/usr/bin/python

"""
usage: ./analysis.py *.txt dimension 
"""

import sys
import os
import string

record = 0
global_min = 9999999999
#w = [4,2,3,4,3]
#p = [[1,2,1],[3,5,4],[7,8,6],[1,2,1],[2,3,2]]
#s = [8,6,190]
w=[262144,3932160,3932160]
p=[[32*300+480*100,25*500,25*480,25*500+30*512],[30*300+480*100,25*500,25*480,99999999],[99999999,4*500,99999999,9999999]]
s=[64*1024, 10000000000, 100000000,6*1024]

def first_j(k,j,c,total_tem):
 global record
 global global_min
 total = total_tem
 if c[j] < w[k]:
  total += 99999999999999999
  return (total, [-1])
 mini = 10000000000000000
 l2 = []
 total += p[k][j]
 #print (c[j])
# print ("j= "+str(j))
 c[j] = c[j] - w[k]
 if total > global_min:
  return (9999999999999,[-1])
 record += 1
 if k == (len(w)-1):
  global_min = total
  return (total,[j])
 #print(total)
 for i in range(0,len(c)):
  (last_min,l_s) = first_j(k+1,i,c,total)
  
  if(mini >  last_min):
   mini = last_min 
   l2 = l_s
 #return (mini,l2) print("array "+ str(k+1)+" put in memory "+ str(l2))
 l3=[j]
 l3.extend(l2)
 return (mini,l3)

min = 999999999999
ll=[]
for j in range(0,len(s)):
 (lastmin,ls)=first_j(0,j,s,0)
 if (min > lastmin):
  min = lastmin
 
  ll = ls
print("total latency= "+str(min))
print(ll)
print(record)
