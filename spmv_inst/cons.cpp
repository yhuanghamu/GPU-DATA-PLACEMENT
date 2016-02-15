#include <stdio.h>
#include <stdlib.h>
#include <algorithm>//#include <list>
#include <vector>
#include <iostream>
#include <string.h>
#include <boost/tokenizer.hpp>
#include <fstream>
#include <sstream>
#include <math.h>
using namespace std;
using namespace boost;
int main(int argc, char *argv[])
{
struct timespec t1,t2,t3;
clock_gettime(CLOCK_MONOTONIC,&t1);
std::vector<int>  size_of;
std::vector<int> dimension;
std::vector<int> block_X;
std::vector<int> block_Y;
std::vector<int> array_size;
std::vector<vector<int> > stride;
int count = 0;
 string line;
    ifstream myfile (argv[9]);
    vector<vector<string>  > dataTable;
 
    if (myfile.is_open())
    {
        while (getline (myfile,line))
        {  count ++;
           stringstream ss(line);
           vector<string> row;
           string entry;
 
           while (ss >> entry)
			   row.push_back(entry);
           dataTable.push_back(row);
        }
        myfile.close();
    }

    else cout << "Unable to open file";

for(int i =0; i<count;i++)
{
	if (dataTable[i][0]=="dimension")
		for(int j = 1; j<dataTable[i].size();j++)
		dimension.push_back(std::stoi(dataTable[i][j]));
		//dimension.assign(dataTable[i].begin()+1,dataTable[i].end());
	else if (dataTable[i][0]=="sizeof")
		 for(int j = 1; j<dataTable[i].size();j++)
                size_of.push_back(std::stoi(dataTable[i][j]));

	else if (dataTable[i][0]=="block_X")
		 for(int j = 1; j<dataTable[i].size();j++)
                block_X.push_back(std::stoi(dataTable[i][j]));

	else if (dataTable[i][0]=="block_Y")
		 for(int j = 1; j<dataTable[i].size();j++)
                block_Y.push_back(std::stoi(dataTable[i][j]));

	else if (dataTable[i][0]=="array_size")
		 for(int j = 1; j<dataTable[i].size();j++)
                array_size.push_back(std::stoi(dataTable[i][j]));
	else
	{
		vector<int> temp;
		for (int j = 0; j<6;j++)
		{
			temp.push_back(std::stoi(dataTable[i][j]));
		}
		stride.push_back(temp);
	}

}
std::sort(stride.begin(),stride.end());
clock_gettime(CLOCK_MONOTONIC,&t2);
cout<<t2.tv_sec-t1.tv_sec+(t2.tv_nsec-t1.tv_nsec)/1.e9<<endl;
//for(int i =0;i<stride.size();i++)
//cout<<stride[i][0]<<" "<<stride[i][1]<<" "<<stride[i][2]<<" "<<stride[i][3]<<" "<<stride[i][4]<<" "<<stride[i][5]<<" "<<endl;
//cout<<size_of<<endl;
int global_size = atoi(argv[1]);
int glo_lat = atoi(argv[2]);
int L2_size = atoi(argv[3]);
int L2_cache_line = atoi(argv[4]);
int L2_lat = atoi(argv[5]);
int L1_size = atoi(argv[6]);
int L1_cache_line = atoi(argv[7]);
int L1_lat = atoi(argv[8]);
if(L2_cache_line < L1_cache_line)
	L2_cache_line = L1_cache_line;
if(L2_size == 0)
 L2_cache_line = size_of[0];
if(L1_size == 0){
 L1_cache_line = size_of[0];
 L1_cache_line = L2_cache_line;
}

if(L2_cache_line < L1_cache_line)
 L2_cache_line = L1_cache_line;
int L1_lines = L1_size/L1_cache_line;
int L2_lines = L2_size/L2_cache_line;
int x=0;
string printout = "global ";
int array = int(stride[x][0]);
int array_next = array;
int rw = int(stride[x][1]);
int exp = int(stride[x][2]);
int loop = int(stride[x][3]);
int index = int(stride[x][5]);
int warp = int(stride[x][4]);
int print1 = 0;
int cache_line = L1_cache_line;
//array_total=[]
int total = 0;
int total_cache_line=0;
std::vector<int> access;
std::vector<int> access_cache_line;
std::vector<int> collect_cache_line;
std::vector<int> L1;
std::vector<int> L2;
int L1_hit = 0;
int L2_hit = 0;
int collect_find = -1;
int L1_find = -1;
int L2_find = -1;
while(x<stride.size())
{
	array_next = int(stride[x][0]);
	int rw_next = int(stride[x][1]);
 	int exp_next = int(stride[x][2]);
 	int loop_next = int(stride[x][3]);
 	int warp_next = int(stride[x][4]);
 	int index_next = int(stride[x][5]);
	x = x + 1;
	if(array == array_next)
	{	
		if(rw==rw_next && exp==exp_next && loop==loop_next && warp/32==warp_next/32)
		{
			index = index_next;
			collect_find = find(collect_cache_line.begin(),collect_cache_line.end(),index_next*size_of[array_next]/cache_line)-collect_cache_line.begin();
			L1_find = find(L1.begin(),L1.end(),index_next*size_of[array_next]/L1_cache_line)-L1.begin();
			if(rw_next ==0 && L1_find < L1.size() \
			&&collect_find>=collect_cache_line.size()  \
			&&abs(L1.size()-L1_find)<=L1_lines)
			{
				L1_hit += 1;
				L1.erase(L1_find+L1.begin());
				L1.push_back(index_next*size_of[array_next]/L1_cache_line);
			}
			else{
				if (rw_next == 0)
				 {
					if(L1_find<L1.size())
						L1.erase(L1_find+L1.begin());
					L1.push_back(index_next*size_of[array_next]/L1_cache_line);
				}
				L2_find = find(L2.begin(),L2.end(),index_next*size_of[array_next]/L2_cache_line)-L2.begin();
				if(L2_find<L2.size() \
				   && collect_find >= collect_cache_line.size() \
				  && abs(L2.size()-L2_find)<=L2_lines)
				{	
					L2_hit += 1;
					L2.erase(L2_find+L2.begin());
					L2.push_back(index_next*size_of[array_next]/L2_cache_line);
				}
				else{
					if(L2_find<L2.size())
						L2.erase(L2_find+L2.begin());
					L2.push_back(index_next*size_of[array_next]/L2_cache_line);
				}
			}
			
			if(collect_find >= collect_cache_line.size())
			collect_cache_line.push_back(index_next*size_of[array_next]/cache_line);
		}
		else{
			exp = exp_next;
			loop = loop_next;
   			warp = warp_next;
   			rw = rw_next;
   			index = index_next;
			access_cache_line.push_back(collect_cache_line.size());
			collect_cache_line.clear();
			collect_find = find(collect_cache_line.begin(),collect_cache_line.end(),index_next*size_of[array_next]/cache_line)-collect_cache_line.begin();
                        L1_find = find(L1.begin(),L1.end(),index_next*size_of[array_next]/L1_cache_line)-L1.begin();
                        if(rw_next ==0 && L1_find < L1.size() \
                        &&collect_find>=collect_cache_line.size()  \
                        &&abs(L1.size()-L1_find)<=L1_lines)
                        {
                                L1_hit += 1;
                                L1.erase(L1_find+L1.begin());
                                L1.push_back(index_next*size_of[array_next]/L1_cache_line);
                        }
                        else{
                                if (rw_next == 0)
                                 {
                                        if(L1_find<L1.size())
                                                L1.erase(L1_find+L1.begin());
                                        L1.push_back(index_next*size_of[array_next]/L1_cache_line);
                                }
                                L2_find = find(L2.begin(),L2.end(),index_next*size_of[array_next]/L2_cache_line)-L2.begin();
                                if(L2_find<L2.size() \
                                   && collect_find >= collect_cache_line.size() \
                                  && abs(L2.size()-L2_find)<=L2_lines)
                                { 
                                        L2_hit += 1;
                                        L2.erase(L2_find+L2.begin());
                                        L2.push_back(index_next*size_of[array_next]/L2_cache_line);
                                }
                                else{
                                        if(L2_find<L2.size())
                                                L2.erase(L2_find+L2.begin());
                                        L2.push_back(index_next*size_of[array_next]/L2_cache_line);
                                }
                        }

                        collect_cache_line.push_back(index_next*size_of[array_next]/cache_line);


		}

	}
	else{
		access_cache_line.push_back(collect_cache_line.size());
		for(int yy=0;yy<access_cache_line.size();yy++)
		{
			total_cache_line += access_cache_line[yy];
		}
		cout<<"array "<<array<<" has "<<total_cache_line<<" transactions,"<<L1_hit<<" L1 hits,"<<L2_hit<<" L2 hits"<<endl;
		array = array_next;
		exp = exp_next;
		loop = loop_next;
		warp = warp_next;
		rw = rw_next;
		total = 0;
		total_cache_line = 0;
		L1_hit = 0;
		L2_hit = 0;
		L1.clear();
		L2.clear();
		access_cache_line.clear();
		collect_cache_line.clear();
		collect_cache_line.push_back(index_next*size_of[array_next]/cache_line);
		L1.push_back(index_next*size_of[array_next]/L1_cache_line);
		L2.push_back(index_next*size_of[array_next]/L2_cache_line);
	}

}
access_cache_line.push_back(collect_cache_line.size());
for(int yy=0;yy<access_cache_line.size();yy++)
 {
      total_cache_line += access_cache_line[yy];
 }
cout<<"array "<<array_next<<" has "<<total_cache_line<<" transactions,"<<L1_hit<<" L1 hits,"<<L2_hit<<" L2 hits"<<endl;
array = array_next;
/*exp = exp_next;
loop = loop_next;
warp = warp_next;
rw = rw_next;
total = 0;
total_cache_line = 0;
 L1.clear();
L2.clear();
access_cache_line.clear();
collect_cache_line.clear();
 collect_cache_line.push_back(index_next*size_of[array_next]/cache_line);
L1.push_back(index_next*size_of[array_next]/L1_cache_line);
L2.push_back(index_next*size_of[array_next]/L2_cache_line);

*/
clock_gettime(CLOCK_MONOTONIC,&t3);
cout<<"time for global: "<<t3.tv_sec-t2.tv_sec+(t3.tv_nsec-t2.tv_nsec)/1.e9<<endl;
  return 0;
//sscanf(p+=n,"%s%n",&pp,&n);
/*while(sscanf(p+=n,"%d%n",&x,&n)>0)
{
 printf("%d ",x);
}

while(p=fgets(buf,sizeof(buf),f))
{
	
}
int line[6];
fscanf(f,"%d %d %d %d %d %d",&line[0],&line[1],&line[2],&line[3],&line[4],&line[5] );

printf("%d %d %d %d %d %d\n", line[0],line[1],line[2],line[3],line[4],line[5]);
*/
return 0;
}
