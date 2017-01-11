#include <iostream.h>
#include <process.h>
#include <alloc.h>

class project;
class spesialist{
    int id,f_day;
    float d_pay;
  public:
    spesialist();
    spesialist(int q);
    float pay(int days);
    int get_id(){return id;}
    friend void programm(project *p,int np,spesialist *&s,int &ns);
};
void spesialist::spesialist()
{
  f_day=1;
  cout<<"����� ��� ������ ��� ����������� (������� ����� int) = ? ";
  cin>>id;
  cout<<"����� ��� �������� ������ ��� ��� ���������� "<<id<<" = ? ";
  cin>>d_pay;
}


void spesialist::spesialist(int q)
{
  f_day=1;
  id=q;
  cout<<"����� ��� �������� ������ ��� ��� ���������� "<<id<<" = ? ";
  cin>>d_pay;
}

float spesialist::pay(int days)
{
  float t_pay;
  t_pay=d_pay*days;
  return t_pay;
}

class project{
    int *special,*days,n;
    int b_day,e_day;
    char id[21];
  public:
    project();
    float cost(spesialist *p,int m);
    int get_b_day(){return b_day;}
    int get_e_day(){return e_day;}
    char *get_id(){return id;}
    friend void programm(project *p,int np,spesialist *&s,int &ns);

};

void project::project()
{
  int i;
  b_day=0;
  e_day=0;
  cout<<"\n����� ��� ������ ��� ����� (max 20 ���������� = ? ";
  cin>>id;
  cout<<"����� ��� ������ ��� ����������� ��� �� ��������� �� ���� "<<id<<" = ? ";
  cin>>n;
  special=(int *)malloc(n*sizeof(int));
  if(special==NULL){
    cout<<"��� ������� ������ ��������� ����� (���� 1)\n";
    exit(1);
  }
  days=(int *)malloc(n*sizeof(int));
  if(special==NULL){
    cout<<"��� ������� ������ ��������� ����� (���� 2)\n";
    exit(1);
  }
  cout<<"��� �� ���� "<<id<<" ����� ��� �����������\n";
  for(i=0;i<n;i++){
    cout<<"����� ��� ������ ��� "<<i+1<<"�� ����������� (������� ����� int) = ? ";
    cin>>special[i];
    cout<<"����� ��� ������ �������� ��� ��� ���������� "<<special[i]<<" = ? ";
    cin>>days[i];
  }
} 

float project::cost(spesialist *p,int m)
{
  int i,j;
  float p_cost=0;
  for(i=0;i<n;i++)
    for(j=0;j<m;j++)
      if(special[i]==p[j].get_id()){
	p_cost+=p[j].pay(days[i]);
	break;
      }
  return p_cost;
}

void add_record(spesialist *&matrix,long &size,spesialist a);
void programm(project *p,int np,spesialist * &s,int &ns);



void programm(project *p,int np,spesialist *&s,int &ns)
{
  int i,j,k,fl,b_d,e_d,f1;
  for(i=0;i<np;i++){
    
    for(j=0;j<p[i].n;j++){
      fl=1;
      for(k=0;k<ns;k++){
	if(p[i].special[j]==s[k].id){
	  if(j==0){
	    b_d=s[k].f_day;
	    e_d=s[k].f_day+p[i].days[j]-1;
	  }
	  else{
	    if(b_d>s[k].f_day) b_d=s[k].f_day;
	    if(e_d<s[k].f_day+p[i].days[j]) e_d=s[k].f_day+p[i].days[j]-1;
	  }
	  s[k].f_day+=p[i].days[j];
	  fl=0;
          break;
	}
      }
      if(fl){
	cout<<"��� �� ���� "<<p[i].get_id()<<" �� ������� �������� �� ��� ���������� "<<p[i].special[j]<<"\n";
	spesialist a(p[i].special[j]);
	long nns=ns;
	spesialist *tem_s=s;
	add_record(tem_s,nns,a);
        s=tem_s;
	ns=nns;
        j--;
      }
    }
  p[i].b_day=b_d;
  p[i].e_day=e_d;
  }
}

void add_record(spesialist *&matrix,long &size,spesialist a)
{
  if(size==0){
    matrix=(spesialist *)malloc(sizeof(spesialist));
    if(matrix==NULL){
      cout<<"��� ������� ������ ��������� ����� (���� 3)\n";
      exit(1);
    }
  }
  else{
    matrix=(spesialist *)realloc(matrix,(1+size)*sizeof(spesialist));
    if(matrix==NULL){
      cout<<"��� ������� ������ ��������� ����� (���� 4)\n";
      exit(1);
    }
  }
  (matrix)[size]=a;
  size++;
}

void main()
{
  spesialist *sp;
  project *pp;
  int i,s_n,p_n,s;
  cout<<"����� ��� ������ ��� �������� ��� �������� � ������� = ? ";
  cin>>s_n;
  if(s_n){
    sp=(spesialist *)malloc(s_n*sizeof(spesialist));
    if(sp==NULL){
      cout<<"��� ������� ������ ��������� ����� (���� 1)\n";
      exit(1);
    }
  }
  for(i=0;i<s_n;i++){
    cout<<"��� ��� "<<i+1<<" �������:\n";
    spesialist tem;
    sp[i]=tem;
  }
  cout<<"\n����� ��� ������ ��� ����� ��� ������� � ������� = ? ";
  cin>>p_n;
  if(p_n){
    pp=(project *)malloc(p_n*sizeof(project));
    if(pp==NULL){
      cout<<"��� ������� ������ ��������� ����� (���� 2)\n";
      exit(1);
    }
  }
  for(i=0;i<p_n;i++){
    project tem;
    pp[i]=tem;
  } 

  programm(pp,p_n,sp,s_n);

  for(i=0;i<p_n;i++){
    cout<<"\n����� ������� ��� ����� "<<pp[i].get_id()<<"   "<<pp[i].get_b_day()<<"\n";
    cout<<"����� ��������� ��� ����� "<<pp[i].get_id()<<"   "<<pp[i].get_e_day()<<"\n";
    cout<<"������ ��� �� ���� "<<pp[i].get_id()<<"   "<<pp[i].cost(sp,s_n)<<"\n";
  }
}

