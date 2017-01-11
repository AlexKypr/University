#include <iostream.h>
#include <process.h>
class circuit_A{
    float R;
    static float V;
    static int nc;
  public:
    circuit_A();
    void pin_out(int a_in,int b_in,int &c_out,int &d_out);
    float get_pow(int a_in,int b_in);
    float get_R(){return R;}
    static char *get_class_id(){return "circuit_A";}
    static void set_V(float v){V=v;}
};
float circuit_A::V;
int circuit_A::nc;

circuit_A::circuit_A()
{
  nc++;
  cout<<"Δώστε την αντίσταση R για το "<<nc<<"o κύκλωμα τύπου circuit_A = ? ";
  cin>>R;
}

float circuit_A::get_pow(int a_in,int b_in)
{
  float ADD_power,OR_power,R_power=0;
  int c_out,d_out;
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
  pin_out(a_in,b_in,c_out,d_out);
  if(c_out-d_out)R_power=V*V/R;
  return ADD_power+OR_power+R_power;
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

class circuit_B{
    float R;
    static float V;
    static int nc;
  public:
    circuit_B();
    void pin_out(int a_in,int b_in,int &c_out,int &d_out);
    float get_pow(int a_in,int b_in);
    float get_R(){return R;}
    static char *get_class_id(){return "circuit_B";}
    static void set_V(float v){V=v;}
};
float circuit_B::V;
int circuit_B::nc;
circuit_B::circuit_B()
{ nc++;
  cout<<"Δώστε την αντίσταση R για το "<<nc<<"o κύκλωμα τύπου circuit_B = ? ";
  cin>>R;
}

float circuit_B::get_pow(int a_in,int b_in)
{
  float ADD_power,OR_power,NOT_power,R_power=0;
  int c_out,d_out;;
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
  pin_out(a_in,b_in,c_out,d_out);
  if(c_out-d_out)R_power=V*V/R;
  return ADD_power+OR_power+NOT_power+R_power;
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
template <class CA,class CB>
class make_circuit{
    float V;
    CA *pA; 
    CB *pB;
    int nCA,nCB;
    int *pos,*cir;
  public:
    make_circuit();
    int *get_pos(){return pos;}
    int *get_cir(){return cir;}
    void cir_sort();
    int get_nCA(){return nCA;}
    int get_nCB(){return nCB;}
    CA *get_pA(){return pA;}
    CB *get_pB(){return pB;}
    ~make_circuit();
};

template <class CA,class CB>
make_circuit<CA,CB>::make_circuit()
{
  cout<<"Δώστε τον αριθμό των κυκλωμάτων τύπου "<<CA::get_class_id()<<" = ? ";
  cin>>nCA;
  pA=new CA[nCA];
  if(pA==0){
    cout<<"Δεν υπάρχει αρκετή διαθέσιμη μνήμη (θέση 1)\n";
    exit(1);
  }
  cout<<"Δώστε τον αριθμό των κυκλωμάτων τύπου "<<CB::get_class_id()<<" = ? ";
  cin>>nCB;
  pB=new CB[nCB];
  if(pB==0){
    cout<<"Δεν υπάρχει αρκετή διαθέσιμη μνήμη (θέση 2)\n";
    exit(1);
  }
  cout<<"Δώστε την τάση V ανάμεσα σε δύο ακροδέκτες με τιμές 0 και 1 = ? ";
  cin>>V;
  CA::set_V(V);
  CB::set_V(V);
  pos=new int[nCA+nCB];
  cir=new int[nCA+nCB];
  if(pos==0 ||cir==0){
  cout<<"Δεν υπάρχει αρκετή διαθέσιμη μνήμη (θέση 3)\n";
    exit(1);
  }
}
template <class CA,class CB>
make_circuit<CA,CB>::~make_circuit()
{
  delete pA;
  delete pB;
  delete pos;
  delete cir;
}

template <class CA,class CB>
void make_circuit<CA,CB>::cir_sort()
{
  int i,item,fl=0,nAB,tn;
  float *R,tem;
  nAB=nCA+nCB;
  R=new float[nAB];
  for(i=0;i<nAB;i++){
    if(i<nCA){
      R[i]=pA[i].get_R();
      pos[i]=i;
      cir[i]=0;
    }
    else{
      R[i]=pB[i-nCA].get_R();
      pos[i]=i-nCA;
      cir[i]=1;
    }
  }
  tn=nAB-1;
  while(!fl){
    fl=1;
    for(i=0;i<tn;i++){
      if(R[i]>R[i+1]){
	tem=R[i];
	R[i]=R[i+1];
	R[i+1]=tem;
	item=pos[i];
	pos[i]=pos[i+1];
	pos[i+1]=item;
	item=cir[i];
	cir[i]=cir[i+1];
	cir[i+1]=item;
	fl=0;
      }
    }
    if(fl)break;
    tn--;
  }
  delete R;
}



template <class CA,class CB>
float calc_circuit(CA *pA,int nCA,CB *pB,int nCB,int *pos,int *cir,int a_in,int b_in,int &c_out,int &d_out)
{
  int i,nAB;
  float power=0;
  nAB=nCA+nCB;
  for(i=0;i<nAB;i++){
    if(cir[i]){
      pB[pos[i]].pin_out(a_in,b_in,c_out,d_out);
      power+=pB[pos[i]].get_pow(a_in,b_in);
    }
    else{
      pA[pos[i]].pin_out(a_in,b_in,c_out,d_out);
      power+=pA[pos[i]].get_pow(a_in,b_in);
    }
    a_in=c_out;
    b_in=d_out;
  }
  return power;
}


void main()
{
  int a_in,b_in,c_out,d_out;
  float pow;
  make_circuit<circuit_A,circuit_B> C;
  C.cir_sort();
  cout<<"Δώστε μια τιμή (0 ή 1) για τον ακροδέκτη a = ? ";
  cin>>a_in;
  cout<<"Δώστε μια τιμή (0 ή 1) για τον ακροδέκτη b = ? ";
  cin>>b_in;

  pow=calc_circuit(C.get_pA(),C.get_nCA(),C.get_pB(),C.get_nCB(),C.get_pos(),C.get_cir(),a_in,b_in,c_out,d_out);
  cout<<"Ισχύς που καταναλώνεται = "<<pow<<"\n";
  cout<<"Ακροδέκτες εισόδου   Ακροδέκτες εξόδου\n";
  cout<<" a = "<<a_in<<"                 c = "<<c_out<<"\n";
  cout<<" b = "<<b_in<<"                 d = "<<d_out<<"\n";
}












  