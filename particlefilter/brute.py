#!/usr/bin/python

"""
usage: ./analysis.py *.txt dimension 
"""

import sys
import os
import string


#w = [4,2,3,4,3]
#p = [[1,2,1],[3,5,4],[7,8,6],[1,2,1],[2,3,2]]
#s = [8,6,190]
w=[8000,8000,8000,8000,8000,8000]
p=[[126*300,126*500,126*600,32*500+1891*30],\
   [127*300+(2016-127)*100,505*500,127*600,4*500+2000*30],\
   [1*300,1*500,1*600,1*500+30],\
   [1*300,1*500,1*600,1*500+30],\
   [99999999,4*500,99999999,16*30+4*500],\
   [99999999,4*500,99999999,16*30+4*500]]
s=[64*1024, 10000000000, 100000000, 8*1024]
print(p)
def first_j(k,j,c,total_tem):
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
 if k == (len(w)-1):
  return (total,[j])
 #print(total)
 for i in range(0,len(c)):
  c1 = []
  for ii in range(0,len(c)):
   c1.append(c[ii])
  (last_min,l_s) = first_j(k+1,i,c1,total)
  
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
