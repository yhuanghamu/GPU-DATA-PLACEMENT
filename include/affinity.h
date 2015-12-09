//This file implements the functions to faciliate the data affinity study
//
//
#include <vector>
#include <set>
#include <list>
#include <iterator>
#include <algorithm>
#include <iostream>
#include "sort.h"

typedef vector<bool>              VecOfBool;
typedef set<int>                  SetOfInt;
typedef list<SetOfInt>            ListOfSetOfInt;
typedef list<SetOfInt>::iterator  ListOfSetOfInt_Iter;
typedef vector<ListOfSetOfInt>    VecOfListOfSetOfInt;
typedef vector<ListOfSetOfInt>::iterator    VecOfListOfSetOfInt_Iter;
typedef vector<int>               VecOfInt;
typedef vector<int>::iterator     VecOfInt_Iter;
typedef vector<float>             VecOfFloat;
typedef vector<float>::iterator   VecOfFloat_Iter;
typedef vector<VecOfFloat>        VecOfVecOfFloat;
typedef set<int>                  SetOfInt;
typedef set<int>::iterator        SetOfInt_Iter;
typedef list<VecOfInt>            ListOfVecOfInt;
typedef vector<VecOfInt>          VecOfVecOfInt;
typedef list<VecOfInt>::iterator  ListOfVecOfInt_Iter;
typedef vector<ListOfVecOfInt>    VecOfListOfVecOfInt;
typedef vector<VecOfInt>::iterator VecOfVecOfInt_Iter;
typedef vector<ListOfVecOfInt>::iterator VecOfListOfVecOfInt_Iter;

//Get the set of cache line IDs for the references
SetOfInt getCacheLines(ListOfSetOfInt &vb, VecOfInt &arraySizes, VecOfInt &eleSizes, int cacheLineSize=128)
{
  int base = 0;
  SetOfInt s;
  for(ListOfSetOfInt_Iter it=vb.begin(), itn=vb.end(); it != itn; ++it) {
    for(SetOfInt_Iter jt= it->begin(), jtn=it->end(); jt != jtn; ++jt) {
      s.insert(arraySizes[base]/cacheLineSize + (*jt)*eleSizes[base]/cacheLineSize);
//      cout << "size = " << it->size() << ", *jt = " << *jt << " s.size() = " << s.size() << endl;
    }
    ++base;
  }
//   int t;
//   cin >> t;
  return s;
}

//a balanced partition to P clusters
VecOfVecOfInt quickPartition(VecOfVecOfFloat &m, int P)
{
  int n = m.size();

  assert(P < n);
  VecOfVecOfInt rv;
  
  for(int i=0; i<n; ++i) {
    VecOfFloat v = m[i];
    VecOfInt tv(v.size());
    gs_quicksort<float>(v, tv);
    rv.push_back(tv);
  }

  VecOfBool mask(n, false);

  //select seeds
  VecOfVecOfInt buckets(P, VecOfInt());  

  //naive selection
//   VecOfInt t(n);
//   for(int i=0; i<n; ++i)
//     t[i] = i;
//   random_shuffle(t.begin(), t.end());
//   for(int i=0; i<P; ++i) {
//     buckets[i].push_back(t[i]);
//     mask[t[i]] = true;
//   }

  //selects nodes as seeds that have low affinity scores among one another (Random //version)
//   VecOfInt rpos(n,n-1);
//   VecOfInt seeds;
//   int t = rand() %n;
//   seeds.push_back(t);
//   mask[t] = true;
//   while(seeds.size() != P) {
//     int i = rand() % seeds.size();
//     int node_i = seeds[i];
//     int node_j = rv[node_i][rpos[node_i]--];
//     if(find(seeds.begin(),seeds.end(), node_j) != seeds.end())
//       continue;
//     seeds.push_back(node_j);
//     cerr << "selected " << node_j << " based on " << node_i << endl;
//     mask[node_j] = true;
//   }
  
  //selects seends of affinity score less than some changing threshold
  float thresh = 0.0;
  SetOfInt seeds;
  int s = rand() % n;
  seeds.insert(s);
  mask[s] = true;
    
  do {
    for(int i=0; i<n; ++i) {
      int k = seeds.size();
      SetOfInt_Iter it = seeds.begin(), itn=seeds.end();
      for( ; it != itn; ++it )
      {
        if(m[i][*it] > thresh) {
         // cerr << "breaking..  m[" << i << "][" << *it << "] = " << m[i][*it] << endl;
          break;
        }
      }
      if(it == itn) {
        seeds.insert(i);
        //cerr << "added " << i << endl;
        mask[i] = true;
        if(seeds.size() == P)
          break;
      }
    }
    thresh += 0.2;
  } while(seeds.size() != P) ;

  cout << "seeds: " << endl;
  int i=0;
  for(SetOfInt_Iter it=seeds.begin(), itn=seeds.end(); it!=itn; ++it) {
    buckets[i++].push_back(*it);
    cout << *it << " ";
  }
  cout << endl;

  //partition the remaining 
  VecOfInt pos(n,0);
  int indB = 0;
  for(int i=P; i<n; ++i) {
    VecOfInt &v = buckets[indB];
    int s = v.size();
    int indv = rand() %s;
    int node_i = v[indv];
    VecOfInt &rv_i = rv[node_i];
    for(int j=pos[node_i]; j < n; ++j) {
      int node_j = rv_i[j];
      //cout << "processing i = " << node_i << " j= " << node_j << endl;
      if(node_i == node_j || mask[node_j] == true) continue;
      //cout << "adding " << node_j << " to bucket " << indB << endl;
      v.push_back(node_j);
      mask[node_j] = true;
      pos[node_i] = j+1;
      break;
    }
    indB = (indB+1>=P) ? 0 : indB+1;
  }

  
//   VecOfInt partition(n);
//   for(int i=0; i<P; ++i) {
//     VecOfInt &b = buckets[i];
//     for(VecOfInt_Iter it=b.begin(),itn=b.end(); it!=itn; ++it)
//       partition[*it] = i;
//   }
  return buckets;
}

//decide the scheduling order of tasks
//k: # of concurrent blks on an SM
int* decideScheduleOrder(VecOfListOfSetOfInt &vvb, VecOfInt &arraySizes, VecOfInt &eleSizes, int nSMs, int k, int cacheLineSize=128)
{
  //obtain affinity matrix
  int n = vvb.size();
  VecOfVecOfFloat affScores(n, VecOfFloat(n));
  for(int i=0; i<n; ++i)
    for(int j=i; j<n; ++j) {
      //Get the affinity score of two thread blocks
      //Assume that the arrays are well aligned (starting from 0)
      //Each vector<int> in the list is the indices of elements accessed in one array
      ListOfSetOfInt vb1 = vvb[i];
      ListOfSetOfInt vb2 = vvb[j];
      const SetOfInt &s1 = getCacheLines(vb1, arraySizes, eleSizes, cacheLineSize);
      const SetOfInt &s2 = getCacheLines(vb2, arraySizes, eleSizes, cacheLineSize);
      int unionSize, intersectionSize;
      SetOfInt su, si;
      set_union(s1.begin(),s1.end(), s2.begin(),s2.end(), inserter(su,su.begin()));
      unionSize = su.size();
      set_intersection(s1.begin(),s1.end(), s2.begin(),s2.end(), inserter(si,si.begin()));
      intersectionSize = si.size();
      affScores[j][i] = float(intersectionSize)/unionSize;
      affScores[i][j] = affScores[j][i];
    }

  //print aff scores
//   for(int i=0; i<n; ++i) {
//     for(int j=0; j<n; ++j) {
//       cerr << affScores[i][j] << " ";
//     }
//     cerr << endl;
//   }

  //do graph partition
  const VecOfVecOfInt &partition = quickPartition(affScores, nSMs);
  
  //decide order in each partition
  int * blkIndOrder = (int*)malloc(n*sizeof(int));
  int l = 0;
  for(int i=0; i<nSMs; ++i)  { 
    const VecOfInt &p = partition[i];
    int m = p.size();
    for(int j=0; j<m; ++j) {
      blkIndOrder[l++] = p[j];
    }
  }
  return blkIndOrder;   
}

//obtain the scheduling based on the neighborlist array
//n: # of threads (One thread uses one index value)
//k: # of concurrent blks on each SM
int * getScheduleOrderFromNeighborList(int nSMs, int *neighborList, int nNeighbors, int n, int blkSize, int k)
{
  VecOfListOfSetOfInt vb;

  for(int i=0; i<n; i += blkSize) {
    ListOfSetOfInt l;
    set<int> s;
    for(int k=0; k<nNeighbors; ++k) {
      s.insert(neighborList+k*n+i, neighborList+k*n+i+blkSize);
    }
    l.push_back(s);
    vb.push_back(l); 
  }

  VecOfInt arraySizes(1,n);
  VecOfInt eleSizes(1,4);
  
  int *order = decideScheduleOrder(vb, arraySizes, eleSizes, nSMs, k); 
  VecOfInt t;
  t.assign(order, order+n/blkSize);
  sort(t.begin(), t.end());
  for(int i=0; i<n/blkSize; ++i)
  {
    if(t[i] != i) {
      cerr << "Something wrong with the order!" << endl;
      cerr << "t[" << i << "] is " << t[i] << endl;
      exit(1);
    }
  }
  cout << endl;
  cout << "order is normal!\n";
  return order;
}

//get scheduling order based on the index array of spmv
int * getScheduleOrderFromIndexArray(int nSMs, int *cols, int *rowDelimiters, int dim, int nRowsPerBlk, int k)
{
  VecOfListOfSetOfInt vb;

  for(int i=0; i<dim; i += nRowsPerBlk) {
    ListOfSetOfInt l;
    set<int> s;
    s.insert(cols+rowDelimiters[i], cols+rowDelimiters[i+nRowsPerBlk]);
//     cout << "blk: " << i/nRowsPerBlk << endl;
//     for(set<int>::iterator it = s.begin(); it != s.end(); ++it)
//       cout << *it << " ";
    cout << endl;
    l.push_back(s);
    vb.push_back(l); 
  }

  VecOfInt arraySizes(1,rowDelimiters[dim]);
  VecOfInt eleSizes(1,4);
  
  int *order = decideScheduleOrder(vb, arraySizes, eleSizes, nSMs, k); 
  VecOfInt t;
  t.assign(order, order+dim/nRowsPerBlk);
  sort(t.begin(), t.end());
  for(int i=0; i<t.size(); ++i)
  {
    if(t[i] != i) {
      cerr << "Something wrong with the order!" << endl;
      cerr << "t[" << i << "] is " << t[i] << endl;
      exit(1);
    }
  }
  cout << endl;
  cout << "order is normal!\n";
  return order;
}
