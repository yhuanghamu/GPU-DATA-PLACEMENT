#include <stdio.h>
#include <stdlib.h>
#include <vector>

using namespace std;



template <typename T>
void SWAP(T &val1, T &val2)
{
	T temp;
	temp = val1;
	val1 = val2;
	val2 = temp;
}


template <typename T>
void gs_quicksort_rec(vector<T> &val, vector<int> &idx, int lower, int upper)
{
	register int i, m;
	register T temp, pivot;
	//if ( (lower < 0) || (upper < 0) || (lower>=199999) || (upper>= 199999)) {
		//printf("lower or upper out of boundary: lower: %d, upper: %d\n", lower, upper);
		////exit(0);
	//}
	//printf("lower, %d, upper, %d\n", lower, upper);
	if ( lower < upper ) {
		SWAP<T>(val[lower], val[(upper+lower)/2]);
		SWAP<int>(idx[lower], idx[(upper+lower)/2]);
		pivot = val[lower];
		m = lower;
		for ( i = lower + 1; i <= upper; i++ )
		{
			if ( val[i] > pivot ) {
				m++;
				SWAP<T>(val[m], val[i]);
				SWAP<int>(idx[m], idx[i]);
			}
		}
		SWAP<T>(val[lower], val[m]);
		SWAP<int>(idx[lower], idx[m]);
		gs_quicksort_rec<T>(val, idx, lower, m-1); //need to check the index array, offset
		gs_quicksort_rec<T>(val, idx, m+1, upper);
	}
}

template <typename T>
void gs_quicksort(vector<T> &val, vector<int> &idx)
{
  int len = val.size();
	//assign values to idx array
	for ( int i=0; i < len; i++ ) idx[i] = i;
	//rec function call quicksort
	gs_quicksort_rec<T>(val, idx, 0, len-1);
}

// template void gs_quicksort<int>(int *, int *, int);
// template void gs_quicksort<float>(float *, int *, int);
// template void gs_quicksort<unsigned int>(unsigned int *, int *, int);
