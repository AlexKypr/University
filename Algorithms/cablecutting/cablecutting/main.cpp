//
//  main.cpp
//  cablecutting
//
//  Created by ALEXANDROS-CHARALAMPOS KYPRIANIDIS on 26/8/16.
//  Copyright © 2016 ALEXANDROS-CHARALAMPOS KYPRIANIDIS. All rights reserved.
//

#include <iostream>
#include <fstream>
using namespace std;

int main(int argc, const char * argv[]) {
    int k,count = 0;
    int **S;
    int N = 20,*V,*L;
    
    
    V = (int *)malloc(sizeof(int)*N);
    L = (int *)malloc(sizeof(int)*N);
    
    string fname = "test.txt";
    ifstream infile(fname);
    if(!infile){
        cout << endl<<"Failed to open file "<<fname;
        return 1;
    }
    while (!infile.eof()) {
        infile >> k;
        V[count] = k;
        count++;
    }
    
    
    
    
    
    for(int i = 0; i < N;i++){
        L[i] = i+1;
    }
    S = (int **)malloc(sizeof(int *)*(N+1));
    for(int i = 0; i <= N; i++){
        S[i] = (int *)malloc(sizeof(int)*(N+1));
    }
    for(int j = 0;j <= N; j++){
        S[0][j] = 0;
    }
    
    for(int i = 1; i <= N ; i++){
        for(int j = 0 ; j <= N ; j++){
            if(j < L[i-1]){
                S[i][j] = S[i-1][j];
            }
            else if(S[i-1][j] > S[i-1][j-L[i-1]] + V[i-1]){
                S[i][j] = S[i-1][j];
            }else if(S[i-1][j] < S[i-1][j-L[i-1]] + V[i-1]){
                S[i][j] = S[i-1][j-L[i-1]] + V[i-1];
            }
            
        }
    }
    
    
    for(int i = 0 ; i<= N;i++){
        for(int j = 0 ; j<= N ;j++){
            cout<<S[i][j]<<" ";
        }
        cout<<endl;
    }
    
    
    free(V);
    free(L);
    return 0;
}
