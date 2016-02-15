#include <stdio.h>
#include <stdlib.h>
#include <algorithm>//#include <list>
#include <vector>
#include <iostream>
using namespace std;
int main(int argc, char * argv[])
{
std::vector<int>  mylist;
for (int i=1; i<=5; ++i) mylist.push_back(i);
int i= find(mylist.begin(),mylist.end(),7)-mylist.begin();
cout<< i<<endl;
return 0;
}
