//
//  main.cpp
//  minweightedsumgreedy
//
//  Created by ALEXANDROS-CHARALAMPOS KYPRIANIDIS on 27/8/16.
//  Copyright © 2016 ALEXANDROS-CHARALAMPOS KYPRIANIDIS. All rights reserved.
//

#include <iostream>
#include <fstream>
using namespace std;

void quickSort(int arr[],int arr2[], int left, int right);

int main(int argc, const char * argv[]) {
    
    int N = 10000,k,l,count = 0;
    int *W,*L,*score,*temp,*sin,*it;
    W = (int *)malloc(sizeof(int)*N);
    L = (int *)malloc(sizeof(int)*N);
    sin = (int *)malloc(sizeof(int)*N);
    score = (int *)malloc(sizeof(int)*N);
    temp = (int *)malloc(sizeof(int)*N);
    it = (int *)malloc(sizeof(int)*N);
    int sum = 0,time = 0;
    
    string fname = "jobs.txt";
    ifstream infile(fname);
    if(!infile){
        cout << endl<<"Failed to open file "<<fname;
        return 1;
    }
    while (!infile.eof()) {
        infile >> k >> l;
        W[count] = k;
        L[count] = l;
        count++;
    }
    
    
    
    
    
    
    
    for(int i = 0; i < N; i++){
        temp[i] = W[i]/L[i];
        sin[i] = i;
    }
    
    quickSort(temp,sin, 0, N-1);
    
    for(int i = 0;i < N ; i++){
        score[i] = temp[N-i-1];
        it[i] = sin[N-i-1];
    }
    for(int i = 0 ; i < N;i++){
        time += L[it[i]];
        sum += W[it[i]]*time;
    }
    cout<<sum<<endl;
    
    return 0;
}

void quickSort(int arr[],int arr2[], int left, int right) {
    int i = left, j = right;
    int tmp,tmp2;
    int pivot = arr[(left + right) / 2];
    
    /* partition */
    while (i <= j) {
        while (arr[i] < pivot)
            i++;
        while (arr[j] > pivot)
            j--;
        if (i <= j) {
            tmp = arr[i];
            arr[i] = arr[j];
            arr[j] = tmp;
            tmp2 = arr2[i];
            arr2[i] = arr2[j];
            arr2[j] = tmp2;
            i++;
            j--;
        }
    };
    
    /* recursion */
    if (left < j)
        quickSort(arr,arr2, left, j);
    if (i < right)
        quickSort(arr,arr2, i, right);
}
