#include <iostream.h>
#include <alloc.h>
#include <process.h>

class matrix{
    float **m;
    int r,c;
  public:
    float *operator[](int k);
    int operator!();
    void operator()(int k,int l);
    int get_r(){return r;}
    int get_c(){return c;}
    void free_mem();
};

float *matrix::operator[](int k)
{ return m[k];}

void matrix::operator()(int k,int l)
{
  int i,j;
  r=k;
  c=l;
  m=(float **)malloc(r*sizeof(float*));
  if(m==NULL){
    cout<<"Δεν υπάρχει διαθέσιμη μνήμη για δέσμευση (θέση 1)\n";
    exit(1);
  }
  for(i=0;i<r;i++){
    m[i]=(float *)malloc(c*sizeof(float));
    if(m[i]==NULL){
      cout<<"Δεν υπάρχει διαθέσιμη μνήμη για δέσμευση (θέση 2)\n";
      exit(1);
    }
  }
  cout<<"Εισάγετε κατά γραμμές τις "<<k*l<<" τιμές των στοιχείων του πίνακα \n";
  for(i=0;i<r;i++)
    for(j=0;j<c;j++)
      cin>>m[i][j];
}
void matrix::free_mem()
{
  int i;
  for(i=0;i<r;i++)
    free(m[i]);
  free(m);
}


int matrix::operator!()
{
  int i,j,k=0;
  float sum,te;
  if(r!=c){
    cout<<"Ο πίνακας δεν είναι τετραγωνικός\n";
    exit(1);
  }
  for(i=0;i<r;i++){
    sum=0;
    for(j=0;j<c;j++){
      if(i==j)continue;
      sum+=m[i][j]>0?m[i][j]:-m[i][j];
    }
    if(sum<(m[i][i]>0?m[i][i]:-m[i][i]))continue;
    sum=0;
    for(j=0;j<c;j++){
      if(i==j)continue;
      sum+=m[j][i]>0?m[j][i]:-m[j][i];
    }
    if(sum>(m[i][i]>0?m[i][i]:-m[i][i]))k=1;
  }
  return k;
}

class vector{
    float *v;
    int n;
  public:
    
    vector(float *p,int k){v=p;n=k;}
    vector(){}
    void operator()(int k);
    vector operator=(matrix a);
    vector operator*(vector a);
    vector operator-(vector a);
    vector operator+(vector a);
    vector operator/(vector a);
    float operator[](int k){return v[k];}
    int vector::operator()(vector nv,float e);
    int get_n(){return n;}
    void out_v();
    void free_mem(){free(v);}
};

void vector::operator()(int k)
{
  int i;
  n=k;
  v=(float *)malloc(n*sizeof(float));
  if(v==NULL){
    cout<<"Δεν υπάρχει διαθέσιμη μνήμη για δέσμευση (θέση 3)\n";
    exit(1);
  }
  cout<<"Εισάγετε "<<k<<" τιμές για τα στοιχεία του διανύσματος  \n";
  for(i=0;i<n;i++)
    cin>>v[i];
}

vector vector::operator=(matrix a)
{
  int i;
  n=a.get_r();
  v=(float *)malloc(n*sizeof(float));
  if(v==NULL){
    cout<<"Δεν υπάρχει διαθέσιμη μνήμη για δέσμευση (θέση 4)\n";
    exit(1);
  }
  for(i=0;i<n;i++)
    v[i]=a[i][i];
  return *this;
}

vector vector::operator*(vector a)
{
  if(n!=a.n){
    cout<<"Δεν είναι δυνατή η εφαρμογή της επικάλυψης  του τελεστή *  για vector * vector\n";
    exit(1);
  }
  vector t;
  t.n=n;
  t.v=(float *)malloc(n*sizeof(float));
  if(t.v==NULL){
    cout<<"Δεν υπάρχει διαθέσιμη μνήμη για δέσμευση (θέση 5)\n";
    exit(1);
  }
  int i;
  for(i=0;i<n;i++)
    t.v[i]=v[i]*a.v[i];
  return t;
}

vector vector::operator-(vector a)
{
  if(n!=a.n){
    cout<<"Δεν είναι δυνατή η εφαρμογή της επικάλυψης  του τελεστή -  για vector - vector\n";
    exit(1);
  }
   vector t;
  t.n=n;
  t.v=(float *)malloc(n*sizeof(float));
  if(t.v==NULL){
    cout<<"Δεν υπάρχει διαθέσιμη μνήμη για δέσμευση (θέση 6)\n";
    exit(1);
  }
  int i;
  for(i=0;i<n;i++)
    t.v[i]=v[i]-a.v[i];
  return t;
}

vector vector::operator+(vector a)
{
  if(n!=a.n){
    cout<<"Δεν είναι δυνατή η εφαρμογή της επικάλυψης  του τελεστή +  για vector + vector\n";
    exit(1);
  }
   vector t;
  t.n=n;
  t.v=(float *)malloc(n*sizeof(float));
  if(t.v==NULL){
    cout<<"Δεν υπάρχει διαθέσιμη μνήμη για δέσμευση (θέση 7)\n";
    exit(1);
  }
  int i;
  for(i=0;i<n;i++)
    t.v[i]=v[i]+a.v[i];
  return t;
}

vector vector::operator/(vector a)
{
  if(n!=a.n){
    cout<<"Δεν είναι δυνατή η εφαρμογή της επικάλυψης  του τελεστή /  για vector / vector\n";
    exit(1);
  }
  vector t;
  t.n=n;
  t.v=(float *)malloc(n*sizeof(float));
  if(t.v==NULL){
    cout<<"Δεν υπάρχει διαθέσιμη μνήμη για δέσμευση (θέση 8)\n";
    exit(1);
  }
  int i;
  for(i=0;i<n;i++)
    t.v[i]=v[i]/a.v[i];
  return t;
}

int vector::operator()(vector nv,float e)
{
  int i;
  float absd;
  if(n!=nv.n){
    cout<<"Δεν είναι δυνατή η εφαρμογή της επικάλυψης  του τελεστή () για vector(vector,float)\n";
    exit(1);
  }
  for(i=0;i<n;i++){
    absd=(v[i]-nv.v[i])>0 ? (v[i]-nv.v[i]) : (nv.v[i]-v[i]);
    if(absd>e)return 0;
  }
  return 1;
}

void vector::out_v()
{
  int i;
  for(i=0;i<n;i++)
    cout<<"v["<<i<<"] = "<<v[i]<<"\n";
}

vector operator*(matrix a,vector x)
{
  int i,j,r,c,n;
  if(a.get_c()!=x.get_n()){
    cout<<"Δεν είναι δυνατή η εφαρμογή της επικάλυψης  του τελεστή () για vector(vector,float)\n";
    exit(1);
  }
  r=a.get_r();
  c=a.get_c();
  n=x.get_n();
  if(c!=n){
    cout<<"Δεν είναι δυνατή η εφαρμογή της επικάλυψης  του τελεστή *  για matrix * vector\n";
    exit(1);
  }
  float *p;
  p=(float *)malloc(r*sizeof(float));
  if(p==NULL){
    cout<<"Δεν υπάρχει διαθέσιμη μνήμη για δέσμευση (θεση 9)\n";
    exit(1);
  }
  for(i=0;i<r;i++){
    p[i]=0;
    for(j=0;j<c;j++)
      p[i]+=a[i][j]*x[j];
  }
  vector t(p,r);
  return t;
}
class system_solve{
    int n;
    matrix a;
    vector b;
  public:
    system_solve(int n);
    vector solve(int k,float e);
    void free_mem(){a.free_mem();b.free_mem();}
};

system_solve::system_solve(int m)
{
  n=m;
  cout<<"Για τον πίνακα των συντελεστών των αγνώστων\n";
  a(m,m);
  cout<<"Για το διάνυσμα των σταθερών όρων\n";
  b(m);
}

vector system_solve::solve(int k,float e)
{
  vector x,nx,d;
  int i;
  cout<<"Για τις αρχικές τιμές της λύσης του συστήματος\n";
  x(n);
  nx=x;
  d=a;
  if((!a)){
    cout<<"Ο πίνακας των συντελεστών των αγνώστων δεν είναι διαγωνίως υπερτερών\nΟ αλγόριθμος δεν συγκλίνει.\n";
    exit(1);
  }
  for(i=0;i<k;i++){
    vector t1,t2,t3,t4;
    t1=a*x;
    t2=d*x;
    t3=b-t1;
    t4=t3+t2;
    nx=t4/d;

    if(nx(x,e))break;
    x=nx;
    t1.free_mem();
    t2.free_mem();
    t3.free_mem();
    t4.free_mem();
  }
  if(i==k)cout<<"Η λύση δεν έχει την ακρίβεια "<<e<<" μετά από "<<k<<" επαναλήψεις\n";
  x.free_mem();
  d.free_mem();
  return nx;
}
    
void main()
{
  int n,m;
  float e;
  cout<<"Δώστε τον αριθμό των εξισώσεων του συστήματος = ? ";
  cin>>n;
  cout<<"Δώστε τον μέγιστο αριθμό επαναλήψεων = ? ";
  cin>>m;
  cout<<"Δώστε την μέγιστη διαφορά μεταξύ δύο διαδοχικών προσεγγίσεων = ? "; 
  cin>>e;
  system_solve R(n);
  vector sol;
  sol=R.solve(m,e);
  sol.out_v();
  R.free_mem();
  sol.free_mem();
}















