---
layout: post
title:  "Beautiful 3 Set"
date:   2017-07-14 20:44:00
categories: programming
use_math: false
---

I was on hackerrank the other day trying to solve ['Beautiful 3 Set'](https://www.hackerrank.com/challenges/beautiful-3-set). The problem goes like this:

You are given an integer `n`. A set, `S`, of triples `(x_i, y_i, z_i)` is beautiful if and only if:
 1. `0 <= x_i, y_i, z_i`
 2. `x_i + y_i + z_i = n`, For all `i` such that `1 <= i <= |S|`
 3. Let X be the set of different `x_i`'s in S, Y be the set of different `y_i`'s in S, and Z be the set of different `z_i` in S. Then `|X| = |Y| = |Z| = |S|`

The third condition means that all `x_i`'s are pairwise distinct. The same goes for `y_i` and `z_i`.

Problem: Given `n`, find any beautiful set having maximum number of elements. Then print the cardinality of `S` on a new line, followed by `|S|` lines where each line contains 3 space-separated integers describing the respective values of `x_i`, `y_i` and `z_i`.

Input Format:

A sample integer, n. (1 <= n <= 300)


# Solution

The solution to this problem is not obvious. Writing out the testcases for the first few `n` is difficult for verification and the questions of uniqueness for each `n` comes up. Is there a quick and easy way of coming up with the solution without having to brute force? The answer to the question is _yes_, because otherwise hackerrank will reject the slow solution. There must be a quick solution and we shall find it (not always the case in general).


At this point I had no real intuition on the problem and decided to brute force the problem first. For the brute force approach, a basic outline of the strategy is to come up with all potential `S` sets and store the largest ones of them for each `n`. We don't know if these `S` sets are unique(excluding column `-(x|y|z)` switching) for a given `n` so we will have to store them all. Now let's get into the specifics of our strategy:


For each `n` we will store all `S` that satisfy the first three conditions described in the problem description. To generate a single `S`, we need some sort of global set to choose from. In other words, we need to generate all valid `(x_i, y_i, z_i)` triples as our basis. Each `(x|y|z)_i` is a number from `0` to `n` (inclusive) and the triplets thus can be generated using a nested for loop with indexes `i` and `j` (once you know the first two numbers then you know the last `z` number since `x+y+z=n`). This gives an upper bound of `O(n^2)` pairs.

Once you have generated all the possible triplets and have filtered all the invalid ones out by the second condition, then you can start generating potential `S` candidates. For any given set `S`, each existing triplet in the basis is either in `S` or not ~ a binary choice. The binary choice is a good hint on some sort of recursive approach. By checking all potential `S` our runtime for this will be `O(2^{|triplet_basis_set_size})` which has an upper bound. Definitely won't work for `n=300` on hackerrank.

Thus the runtime of our brute force approach is `O(2^{n^2})` (it is easy to optimize the brute force algorithm... but it would still be too slow for hackerrank). That is crazy slow! This is why we are doing this brute force approach on our machine and not hackerrank. Here is the brute force code:
```
#include <iostream>
#include <fstream>
#include <sstream>

using namespace std;

int n_limit = 20;

bool is_file_exist(const char *fileName){
    std::ifstream infile(fileName);
    return infile.good();
}


/*
x,y,z array are responsible for storing the basis of triples from which we select
The ith indeces of these arrays contain the ith triple.

index represents the current index we are looking at in our recursive binary method

//curNum is the current number we are processing (from n_limit)
this is useful for file writing/appending
*/
int generatingS(int * x,int * y,int * z,int index,int arrLength, int *x_cov, int *y_cov, int *z_cov, int max, int curNum){
	
	//not enough space left to maximize set
	//TODO: implement this feature

	if(index==arrLength){
		//we reached the bottom. check the set size by counting x_cov
		//and returning that number 
		int size=0;
		for(int i = 0; i < curNum+1; i++){
			if(x_cov[i]!=0){
				size++;
			}
		}
		if(max > size){//current entry is not bigger
			return max;
		}			
		//write it to file
		
		std::ofstream outfile;

		stringstream ss;
		ss<<curNum<<".txt";
		
		outfile.open(ss.str(), std::ios_base::app);
		outfile<<size<<endl;
		for(int i = 0; i < curNum+1; i++){
			if(x_cov[i]!=0){//output out all the pairs
				outfile<<x[x_cov[i]-1]<<" "<<y[x_cov[i]-1]<<" "<<z[x_cov[i]-1]<<endl;
			}
		}outfile<<endl;

		
		return size;
	}
	

	//assume that (x[index], y[index], z[index]) is in S
	//in order to make this assumption valid we need to check if 
	//(x|y|z)[index] has already been tagged in (x|y|z)_cov[(x|y|z)[index]]
	//This is an optimization that says if this triplet can't possibly be
	//part of the solution the don't recurse further with assumption that it is
	//part of solution
	if(x_cov[x[index]]==0&&y_cov[y[index]]==0&&z_cov[z[index]]==0){
		//tag so that inner layers of recursion now that the numbers in triplet
		//are in use
		x_cov[x[index]]=index+1;
		y_cov[y[index]]=index+1;
		z_cov[z[index]]=index+1;
		max = generatingS(x,y,z,index+1,arrLength,x_cov,y_cov,z_cov,max,curNum);
		
		//untag the values
		x_cov[x[index]]=0;
		y_cov[y[index]]=0;
		z_cov[z[index]]=0;
	}
	
	//assume that (x[index], y[index], z[index]) is not in S
	max = generatingS(x,y,z,index+1,arrLength,x_cov,y_cov,z_cov,max,curNum);
	return max;
}


int main(){
	for(int n = 2; n <= n_limit; n++){
		cout<<n<<endl;
		int index = 0;
		int upperBound = n*n;
		int * basis_x = new int[upperBound];
		int * basis_y = new int[upperBound];
		int * basis_z = new int[upperBound];
		//first generate the triplet basis
		//(since i,j,k start at zero then condition 1 auto satisfied) 
		for(int i = 0; i <= n; i++){
			for(int j = 0; j <= n-i; j++){
				int k = n-j-i;
				//satifies condition 2: add to our basis
				basis_x[index] = i;
				basis_y[index] = j;
				basis_z[index] = k;
				//cout<<i<<" "<<j<<" "<<k<<endl;
				index++;	
			}
		}cout<<index<<endl<<endl;//continue;
		
		//output all pairs
		//for(int i = 0; i < index; i++){
			//cout<<basis_x[index]<<" "<<basis_y[index]<<" "<<basis_z[index]<<endl;
		//}
		
		
		//we now have our basis and we can now generate all S
		int *x_cov = new int[n+1];
		int *y_cov = new int[n+1];
		int *z_cov = new int[n+1];
		for(int i = 0; i <= n; i++){
			x_cov[i] = 0;
			y_cov[i] = 0;
			z_cov[i] = 0;
		}
		generatingS(basis_x,basis_y,basis_z,0,index,x_cov,y_cov,z_cov,0,n);
		
		
		delete [] basis_x;
		delete [] basis_y;
		delete [] basis_z;
		delete [] x_cov;
		delete [] y_cov;
		delete [] z_cov;
	}
}

```

I only had the patience to run up to `n = 17`. I observed that there were many sets of max `|S|` stored for each `n`. Given the way the basis was derived and the recursive function ran, I decided to only filter for the first max `|S|` printed for each `n`. Here are the first for `n=2` to `n=17`:

```
n=2:
2
0 0 2
1 1 0
n=3:
3
0 1 2
1 2 0
2 0 1
n=4:
3
0 0 4
1 1 2
2 2 0
n=5:
4
0 0 5
1 2 2
2 3 0
3 1 1

n=6:
5
0 2 4
1 3 2
2 4 0
3 0 3
4 1 1

n=7:
5
0 0 7
1 1 5
2 3 2
3 4 0
4 2 1

n=8:
6
0 0 8
1 3 4
2 4 2
3 5 0
4 1 3
5 2 1

n=9:
7
0 3 6
1 4 4
2 5 2
3 6 0
4 0 5
5 1 3
6 2 1

n=10:
7
0 0 10
1 1 8
2 4 4
3 5 2
4 6 0
5 2 3
6 3 1

n=11:
8
0 0 11
1 4 6
2 5 4
3 6 2
4 7 0
5 1 5
6 2 3
7 3 1

n=12:
9
0 4 8
1 5 6
2 3 7
3 7 2
4 8 0
5 6 1
6 1 5
7 2 3
8 0 4

n=13:
9
0 0 13
1 1 11
2 5 6
3 6 4
4 7 2
5 8 0
6 2 5
7 3 3
8 4 1

n=14:
10
0 0 14
1 5 8
2 6 6
3 4 7
4 8 2
5 9 0
6 7 1
7 2 5
8 3 3
9 1 4

n=15:
11
0 5 10
1 6 8
2 4 9
3 7 5
4 9 2
5 10 0
6 8 1
7 1 7
8 3 4
9 0 6
10 2 3

n=16:
11
0 0 16
1 1 14
2 6 8
3 7 6
4 5 7
5 9 2
6 10 0
7 8 1
8 3 5
9 4 3
10 2 4

n=17:
12
0 0 17
1 6 10
2 7 8
3 5 9
4 8 5
5 10 2
6 11 0
7 9 1
8 2 7
9 4 4
10 1 6
11 3 3
```

This once again does not tell us much other than the fact that there exists a combination with max |S| such that the `x`'s can be ordered from `0` to some sort of limit. Is it guaranteed that for all n the `x`'s can be ordered? We will assume for now that the answer is yes. The pattern for the `y` and `z` are not clear either. I decided to treat `y-z` row values as coordinates on a `y-z` plane and plot them. Here is a plot for `n=9`:

|-|0 | 1| 2| 3| 4| 5 | 6| 7| 8| 9|
|--|--|--|--|--|--|--|--|--|--|--|
|**0**| 0 | 1 | 2 | 3 | 4| `5`| 6| 7| 8| 9|
|**1** | 1 | 2| 3| `4`| 5 | 6| 7| 8| 9| 10|
|**2** | 2 | `3`| 4| 5| 6| 7| 8 | 9 | 10| 11|
|**3** | 3 | 4| 5| 6| 7| 8| `9` | 10 | 11| 12|
|**4** | 4| 5| 6| 7| `8`| 9 | 10| 11| 12| 13|
|**5** | 5 | 6| `7`| 8| 9 | 10| 11| 12| 13| 14|
|**6** | `6` | 7| 8| 9| 10| 11| 12| 13| 14 | 15|
|**7** | 7 | 8 |9|10|11|12|13|14|15|16|
|**8** | 8 | 9| 10| 11| 12| 13| 14| 15| 16| 17|
|**9** | 9 | 10| 11| 12| 13| 14| 15| 16| 17|18|







The rows and column labels represent different potential values for `y` and `z` (first col is `y` values and first row is `z` values), the entries on `(y,z)` coordinates is the sum: `y+z`. This is done because as the `x` column values increase one by one then, by definition, the sum of the `y` and `z` entry must decrease by one. This can be observed visually on the graph as each highlighted number is unique. In addition, we know that all numbers in the `x` column are unique and therefore the values in the `y` and `z` columns must also be unique. Graphically, this translates to no row or column having more than one circled number and the equal sum present in each (anti) diagonal corresponds to a specific x value since `x+y+z=n`.

We thus have translated our problem to a different, more visual one. Our translation is somewhat similar to the [Eight(N) queens puzzle](https://en.wikipedia.org/wiki/Eight_queens_puzzle): no highlighted-number/queen can appear in the same column/row/(antidiagonal) on the matrix/chessboard with no pieces below the main `y+z=n` diagonal. This translation gives us more insight into the restrictions on the values in the triplets and really drives the point home that this problem is only in terms of `y` and `z`.

If we go back and plot from `n=2` to `n=18` then one notices there is no pattern amongst the different `n`'s and no natural way to build up the solution. This is slightly disappointing because the printed `n=` results were the first from max `|S|` found in the brute force code. The hope is that by recording the first result, we would have had caught some sort of relation between the different `n`.


Nonetheless, we know what the `|S|` size is and have a very simple visual way of coming up with new potential solutions. The simple solution for all `n` followed the `n=9` pattern (after playing around a bit with the different 'n-chessboard' it becomes clear). There are two diagonal like lines. Bottom one starts (bottom-left) at some number (for `n=9` it is `(y,z)=(6,0)`) and the consecutive entries in diagonal like line are located at `(y-1, z+2)` all the way up until `y+z=n`. The top diagonal like line starts with `y'=y-1` from previous `y` when `y+z=n`. The first(left-bottom most) `z` for top diagonal is `z=1`. Top diagonal increases in same fashion as bottom one until bounds of 'chessboard' are hit.

Our solution now does not depend on `y` and `z` but on the left most number of the bottom row. If you plot out the 'chessboards' for first 10 `n`, then when will notice that the pattern is `mod 3` and thus the `O(n)` solution is formed:

```
#include <cmath>
#include <cstdio>
#include <vector>
#include <iostream>
#include <algorithm>
using namespace std;


int main() {
    int n;cin>>n;
    
    int pairCount = 0;
    vector <int> x_y_zPairsOrdered;
    int y=0,z=0,x=0;
    if(n%3==0){
        y=(2*n)/3 ; 
    }
    else if(n%3==1){
        y=(2*n - 2) /3 ;
    }
    else{//n%3==2
        y=( 2*n-1 )/3;
    }
    
    //bottom diagonal from left to right
    do{
        x=n-y-z;
        x_y_zPairsOrdered.push_back(x);
        x_y_zPairsOrdered.push_back(y);
        x_y_zPairsOrdered.push_back(z);
        y-=1;
        z+=2;
        pairCount++;
    }while(y+z <= n);
    
    //upper diagonal from left to right
    z=-1;
    for(;y >= 0;y--){
        z+=2;
        x=n-z-y;
        pairCount++;
        x_y_zPairsOrdered.push_back(x);
        x_y_zPairsOrdered.push_back(y);
        x_y_zPairsOrdered.push_back(z);
    }
    
    
    //output:
    cout<<pairCount<<endl;
    for(int i = 0; i < pairCount; i++){
        cout<<x_y_zPairsOrdered[i*3]<<" ";
        cout<<x_y_zPairsOrdered[i*3+1]<<" ";
        cout<<x_y_zPairsOrdered[i*3+2]<<" ";
        cout<<endl;
    }
    
}

```

### Conclusion

The main idea I wanted to push in this article is that in order to solve complex problems such as the ones present in hackerrank, it is OK to take a two step approach and brute it on your machine first. It is OK to try a stupid solution first. It is all about discovery.

Sometimes it is sufficient to simply work through some examples by hand to notice a pattern when solving these problems. However, sometimes that can be difficult to do and verify correctness of and a two step solution can help crack the problem.

Unfortunately, this tip is not the silver/magic bullet to solving 'Hard' problems on hackerrank. Oftentimes, the input to the problem is hard to formulate to begin with (like some graph with complex properties). In our case, we were just given a number n, which is easy to generate as input and easy to generate potential output for and test for correctness. Nonetheless, this approach gave me the opportunity to solve the problem by myself and learn something new during the process. That is always welcome.





