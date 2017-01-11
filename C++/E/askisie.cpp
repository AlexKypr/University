#include <iostream.h>
#include <process.h>
#include <malloc.h>
class circuit{
  public:
    virtual void pin_out(int a_in,int b_in,int &c_out,int &d_out)=0;
    virtual float get_pow(int a_in,int b_in)=0;
};

class circuit_A:public circuit{
  public:
    void pin_out(int a_in,int b_in,int &c_out,int &d_out);
    float get_pow(int a_in,int b_in);
};

float circuit_A::get_pow(int a_in,int b_in)
{
  float ADD_power,OR_power;
  if(a_in==0 && b_in==0){
    ADD_power=0;
    OR_power=0;
  }
  if(a_in==1 && b_in==0){
    ADD_power=0.5;
    OR_power=0.5;
  }
  if(a_in==0 && b_in==1){
    ADD_power=0.5;
    OR_power=0.5;
  }
  if(a_in==1 && b_in==1){
    ADD_power=1;
    OR_power=1;
  }
  return ADD_power+OR_power;
}

void circuit_A::pin_out(int a_in,int b_in,int &c_out,int &d_out)
{
  if(a_in==0 && b_in==0){
    c_out=0;
    d_out=0;
  }
  if(a_in==0 && b_in==1){
    c_out=0;
    d_out=1;
  }
  if(a_in==1 && b_in==0){
    c_out=0;
    d_out=1;
  }
  if(a_in==1 && b_in==1){
    c_out=1;
    d_out=1;
  }
}

class circuit_B:public circuit{
  public:
    void pin_out(int a_in,int b_in,int &c_out,int &d_out);
    float get_pow(int a_in,int b_in);
};

float circuit_B::get_pow(int a_in,int b_in)
{
  float ADD_power,OR_power,NOT_power;
  if(a_in==0 && b_in==0){
    ADD_power=0.5;
    OR_power=0;
    NOT_power=0;
  }
  if(a_in==1 && b_in==0){
    ADD_power=1;
    OR_power=0.5;
    NOT_power=0;
  }
  if(a_in==0 && b_in==1){
    ADD_power=0;
    OR_power=0.5;
    NOT_power=1;
  }
  if(a_in==1 && b_in==1){
    ADD_power=0.5;
    OR_power=1;
    NOT_power=1;
  }
  return ADD_power+OR_power+NOT_power;
}

void circuit_B::pin_out(int a_in,int b_in,int &c_out,int &d_out)
{
  if(a_in==0 && b_in==0){
    c_out=0;
    d_out=0;
  }
  if(a_in==0 && b_in==1){
    c_out=0;
    d_out=1;
  }
  if(a_in==1 && b_in==0){
    c_out=1;
    d_out=1;
  }
  if(a_in==1 && b_in==1){
    c_out=0;
    d_out=1;
  }
}

float calc_circuit(circuit **C,int n,int a_in,int b_in,int &c_out,int &d_out)
{
  int i;
  float power=0;
  for(i=0;i<n;i++){
    C[i]->pin_out(a_in,b_in,c_out,d_out);
	 a_in=c_out;
	 b_in=d_out;
	 power+=C[i]->get_pow(a_in,b_in);
  }
  return power;
}

void main()
{
  int i,k,a_in,b_in,c_out,d_out,N,nA,nB,Ac=0,Bc=0;
  float power;
  circuit **P;
  circuit_A *AP;
  circuit_B *BP;
  cout<<"����� ��� ������ ��� ����������� ���������� ����� � = ? ";
  cin>>nA;
  cout<<"����� ��� ������ ��� ����������� ���������� ����� B = ? ";
  cin>>nB;
  N=nA+nB;
  if(!(AP=new circuit_A[nA])){
    cout<<"��� ������� ������ ��������� ����� (���� 1)\m";
    exit(1);
  }
  if(!(BP=new circuit_B[nB])){
    cout<<"��� ������� ������ ��������� ����� (���� 2)\m";
    exit(2);
  }
  if(!(P=new circuit *[N])){
    cout<<"��� ������� ������ ��������� ����� (���� 3)\m";
    exit(3);
  }
  i=0;
  while(i<N){
	 cout<<"����� ��� ���� ��� ���������� ��� �� �������� ��� ���� "<<i+1<<"(1 ��� ��� ���� �, 2 ��� ��� ���� �) = ? ";
    cin>>k;
    if(k==1){
      if(nA==0||Ac>=nA){
	cout<<"��� �������� ��������� ����� � ��� �� ���������\n";
	continue;
      }
      else{
        P[i]=&AP[Ac];
	Ac++;
        i++;
      }
    }
     
    if(k==2){
      if(nB==0||Bc>=nB){
	cout<<"��� �������� ��������� ����� B ��� �� ���������\n";
	continue;
      }
      else{
        P[i]=&BP[Bc];
	Bc++;
        i++;
      }
    }
  }
  cout<<"����� ��� ���� ���� ��������� a = ? ";
  cin>>a_in;
  cout<<"����� ��� ���� ���� ��������� b = ? ";
  cin>>b_in;

  power=calc_circuit(P,N,a_in,b_in,c_out,d_out);

  cout<<"���� ����� � ���������� c �� ���� ���� "<<c_out<<" ��� � ���������� d ���� "<<d_out<<"\n";
  cout<<"� �������� ����� ��� ����������� �� ������� ����� "<<power<<" mwatt\n";
  delete P;
  delete AP;
  delete BP;
}