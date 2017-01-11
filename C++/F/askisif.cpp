#include <iostream.h>
#include <alloc.h>
#include <stdlib.h>
class source{
  protected:
    static source **S;
    static int N;
    static source **DU;
    static int NU;
  public:
    virtual float get_pow()=0;
    virtual int set_conditions()=0;
    virtual char *get_id()=0;
    virtual void free_mem()=0;

    static source **get_S(){return S;}
    static int get_N(){return N;}
    static source **get_DU(){return DU;}
    static int get_NU(){return NU;}
};

source **source::S;
int source::N=0;
source **source::DU;
int source::NU=0;

class sun_source:public source{
    float pow,area,lumen,Sun,p_damage;
    char id[11];
    static int nm;
    static sun_source *p;
    int a_a;
    
  public:
    float get_pow();
    int set_conditions();
    char *get_id(){return id;}
    void free_mem(){delete [nm]p;}
    sun_source();
    static int create_units();
    ~sun_source(){cout<<id<<"  off\n";}
};
int sun_source::nm=sun_source::create_units();
sun_source *sun_source::p;

int sun_source::create_units()
{
  int num;
  cout<<"Δώστε τον αριθμό των πηγών τύπου sun_source = ? ";
  cin>>num;
  p=new sun_source[num];
  if(p==0){
    cout<<"Δεν υπάρχει αρκετή διαθέσιμη μνήμη (θέση 1)\n";
    exit(1);
  }
  NU++;
  if(NU==1){
    DU=(source **)malloc(NU*sizeof(source *));
    if(DU==NULL){
      cout<<"Δεν υπάρχει αρκετή διαθέσιμη μνήμη (θέση 2)\n";
      exit(1);
    }
  }
  else{
    DU=(source **)realloc(DU,NU*sizeof(source *));
    if(DU==NULL){
      cout<<"Δεν υπάρχει αρκετή διαθέσιμη μνήμη (θέση 3)\n";
      exit(1);
    }
  }
  DU[NU-1]=p;
  return num;
}

sun_source::sun_source()
{
  nm++;
  a_a=nm;
  cout<<"Δώστε την ταυτότητα της "<<a_a<<"ης πηγής τύπου sun_source (MAX 10 chars) = ? ";
  cin>>id;
  cout<<"Δώστε την επιφάνεια του συλλέκτη = ? ";
  cin>>area;
  cout<<"Δώστε τον συντελεστή απόδοσης = ? ";
  cin>>Sun;
  cout<<"Δώστε την πιθανότητα βλάβης της πηγής = ? ";
  cin>>p_damage;
  N++;
  if(N==1){
    S=(source **)malloc(N*sizeof(source *));
    if(S==NULL){
      cout<<"Δεν υπάρχει αρκετή διαθέσιμη μνήμη (θέση 4)\n";
      exit(1);
    }
  }
  else{
    S=(source **)realloc(S,N*sizeof(source *));
    if(S==NULL){
      cout<<"Δεν υπάρχει αρκετή διαθέσιμη μνήμη (θέση 5)\n";
      exit(1);
    }
  }
  S[N-1]=this;
} 

float sun_source::get_pow()
{
  pow=area*lumen*Sun;
  return pow;
}

int sun_source::set_conditions()
{
  float p;
  p=(float)(rand()%1000)/1000.;
  if(p<p_damage)return 1;
  cout<<"Δώστε την ένταση της φωτεινής ροής στην πηγή "<<id<<" = ? ";
  cin>>lumen;
  return 0;
}

class air_generator:public source{
    float pow,velocity,Air,p_damage;
    static int nm;
    static air_generator *p;
    int a_a;
    char id[11];
  public:
    float get_pow();
    int set_conditions();
    char *get_id(){return id;}
    air_generator();
    void free_mem(){delete [nm]p;}
    static int create_units();
    ~air_generator(){cout<<id<<"  off\n";}
};

int air_generator::nm=air_generator::create_units();
air_generator *air_generator::p;
int air_generator::create_units()
{
  int num;
  cout<<"Δώστε τον αριθμό των πηγών τύπου air_generator = ? ";
  cin>>num;
  p=new air_generator[num];
  if(p==0){
    cout<<"Δεν υπάρχει αρκετή διαθέσιμη μνήμη (θέση 6)\n";
    exit(1);
  }
  NU++;
  if(NU==1){
    DU=(source **)malloc(NU*sizeof(source *));
    if(DU==NULL){
      cout<<"Δεν υπάρχει αρκετή διαθέσιμη μνήμη (θέση 7)\n";
      exit(1);
    }
  }
  else{
    DU=(source **)realloc(DU,NU*sizeof(source *));
    if(DU==NULL){
      cout<<"Δεν υπάρχει αρκετή διαθέσιμη μνήμη (θέση 8)\n";
      exit(1);
    }
  }
  DU[NU-1]=p;
  return num;
}


air_generator::air_generator()
{
  nm++;
  a_a=nm;
  cout<<"Δώστε την ταυτότητα της "<<a_a<<"ης πηγής τύπου air_generator (MAX 10 chars) = ? ";
  cin>>id;
  cout<<"Δώστε τον συντελεστή απόδοσης για την ανεμογεννήτρια = ? ";
  cin>>Air;
  cout<<"Δώστε την πιθανότητα βλάβης της πηγής = ? ";
  cin>>p_damage;
  N++;
  if(N==1){
    S=(source **)malloc(N*sizeof(source *));
    if(S==NULL){
      cout<<"Δεν υπάρχει αρκετή διαθέσιμη μνήμη (θέση 9)\n";
      exit(1);
    }
  }
  else{
    S=(source **)realloc(S,N*sizeof(source *));
    if(S==NULL){
      cout<<"Δεν υπάρχει αρκετή διαθέσιμη μνήμη (θέση 10)\n";
      exit(1);
    }
  }
  S[N-1]=this;
}

float air_generator::get_pow()
{
  pow=velocity*Air;
  return pow;
}

int air_generator::set_conditions()
{
  float p;
  p=(float)(rand()%1000)/1000.;
  if(p<p_damage)return 1;
  cout<<"Δώστε την ταχύτητα του ανέμου στην πηγή "<<id<<" = ? ";
  cin>>velocity;
  return 0;
}

int control(source **S,int n,float n_pow,float &pow,float &d_pow)
{
  int i,m;
  pow=0;
  for(i=0;i<n;i++){
    m=S[i]->set_conditions();
    if(m){
      cout<<"Η πηγή "<<S[i]->get_id()<<" είναι εκτός λειτουργίας\n";
      continue;
    }
    pow+=S[i]->get_pow();
  }
  if(n_pow>pow){
    d_pow=n_pow-pow;
    return 1;
  }
  if(pow<n_pow*1.1)
    return 2;
  return 3;
}

void main()
{
  source **S;
  int n,ch,Alarm,i;
  float n_pow,pow,d_pow;
  cout<<"Δώστε την ισχύ που απαιτεί ο σταθμός = ? ";
  cin>>n_pow;
  S=source::get_S();
  n=source::get_N();
 
   Alarm=control(S,n,n_pow,pow,d_pow);
   if(Alarm==1){
     cout<<"Η ισχύς δεν επαρκεί\n";
     cout<<"Απαιτούμενη ισχύς         "<<n_pow<<"\n";
     cout<<"Ισχύς που αποδίδεται      "<<pow<<"\n";
     cout<<"Έλλειμμα ισχύος           "<<d_pow<<"\n";
   }
   if(Alarm==2){
     cout<<"Η ισχύς είναι κάτω από το όριο ασφαλείας\n";
     cout<<"Απαιτούμενη ισχύς         "<<n_pow<<"\n";
     cout<<"Ισχύς που αποδίδεται      "<<pow<<"\n";
   }
   if(Alarm==3)
     cout<<"Η τροφοδοσία γίνεται ομαλά\n";
   for(i=0;i<source::get_NU();i++)
     source::get_DU()[i]->free_mem();
}

    