//
//  main.cpp
//  Knapsack
//
//  Created by ALEXANDROS-CHARALAMPOS KYPRIANIDIS on 25/8/16.
//  Copyright © 2016 ALEXANDROS-CHARALAMPOS KYPRIANIDIS. All rights reserved.
//

#include <iostream>
#include <fstream>

using namespace std;
int knapsack(int *V,int *W,int cap,int total);
int main(int argc, const char * argv[]) {
    int *V,*W;
    int cap = 10000,total = 100,k,l,count = 0,final;
    V = (int *)malloc(sizeof(int)*total);
    W = (int *)malloc(sizeof(int)*total);
    
    
    
    string fname = "knap.txt";
    ifstream infile(fname);
    if(!infile){
        cout << endl<<"Failed to open file "<<fname;
        return 1;
    }
    while (!infile.eof()) {
        infile >> k >> l;
        V[count] = k;
        W[count] = l;
        count++;
    }
    
    
    
    
    final = knapsack(V,W,cap,total);
    cout << final<<endl;
    return 0;
}

int knapsack(int *V,int *W,int cap,int total){
    int **A;
    A = (int **)malloc(sizeof(int *)*(total+1));
    for(int i = 0; i <= total; i++){
        A[i] = (int *)malloc(sizeof(int)*(cap+1));
    }
    for(int j = 0;j <= cap; j++){
        A[0][j] = 0;
    }
    for(int i = 1; i <= total; i++){
        for(int j = 0; j<= cap;j++){
            if(W[i-1] > j){
                A[i][j] = A[i-1][j];
            }else if(A[i-1][j] > A[i-1][j-W[i-1]] + V[i-1]){
                A[i][j] = A[i-1][j];
            }else if(A[i-1][j] < A[i-1][j-W[i-1]] + V[i-1]){
                A[i][j] = A[i-1][j-W[i-1]] + V[i-1];
            }
        }
    }
    for(int i = 0 ; i<= total;i++){
        for(int j = 0 ; j<= cap ;j++){
            cout<<A[i][j]<<" ";
        }
        cout<<endl;
    }
    return A[total][cap];
}




