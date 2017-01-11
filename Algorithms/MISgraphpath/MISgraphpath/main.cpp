//
//  main.cpp
//  MISgraphpath
//
//  Created by ALEXANDROS-CHARALAMPOS KYPRIANIDIS on 25/8/16.
//  Copyright © 2016 ALEXANDROS-CHARALAMPOS KYPRIANIDIS. All rights reserved.
//

#include <iostream>
using namespace std;
int main(int argc, const char * argv[]) {
    int V[20] = {2,4,6,1,3,6,3,4,6,3,1,6,7,4,26,4,5,26,46,2};
    int A[21];
    A[0] = 0;
    A[1] = V[0];
    for(int i = 2;i <= 20;i++){
        if(A[i-1] >= A[i-2] + V[i-1]){
            A[i] = A[i-1];
        }else if(A[i-1] < A[i-2] + V[i-1]) {
            A[i] = A[i-2] + V[i-1];
        }
        cout<<A[i]<<endl;
    }
    
    return 0;
}
