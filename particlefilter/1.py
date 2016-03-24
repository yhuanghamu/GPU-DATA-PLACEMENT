#!/usr/bin/python

import sys
import os
from itertools import *
import time
import subprocess


for ben1 in range(0,10):
 exe_command='./1 -x 128 -y 128 -z 2 -np 1000 > running/'+str(ben1)+'.out'
 print(exe_command)
 os.system(exe_command)
num=0.0
for ben1 in range(0,10):
 filename='running/'+str(ben1)+'.out'
 s1="grep "+"\"CUDA EXEC TOOK:\" "+ filename+" |awk \'{print \" \"\" \" $4\"  \"}\'"
 os.system(s1+">s1.txt")
 s1_f=open("s1.txt",'r')
 for line in s1_f:
  line=line.strip()
  num+=float(line)
num=num/10
print("average kernel time= "+str(num))
