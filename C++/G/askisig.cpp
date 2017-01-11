#include <iostream.h>
#include <alloc.h>
class neuron{
    int id,*neighbour_id,n,state;
    float threshold,*sinaps;
  public:
	 friend istream &operator>(istream &s , neuron &a);
	 friend ostream &operator<(ostream &s, neuron a);
    void *operator new[](size_t size);
    void operator delete(void *W);
    int get_id(){return id;}
    int get_state(){return state;}
    int get_n(){return n;}
    float get_sinaps(int i){return sinaps[i];}
    float get_threshold(){return threshold;}
    int get_neighbour(int i){return neighbour_id[i];}
    void set_state(int i){state=i;}
};

void *neuron::operator new[](size_t size)
{
 int i,n;
 neuron *p;
 p=(neuron *)malloc(size);
 n=size/sizeof(neuron);
 for(i=0;i<n;i++){
   p[i].id=i;
   cout<<"����� ��� ������ ��� ��������� ��� ������� "<<p[i].id<<" = ? ";
   cin>>p[i].n;
   p[i].neighbour_id=new int[p[i].n];
   p[i].sinaps=new float[p[i].n];
	cin>p[i];
 }
 return p;
}

void neuron::operator delete(void *W)
{
  delete(((neuron *)W)->neighbour_id);
  delete(((neuron *)W)->sinaps);
}

istream &operator>(istream &s , neuron &a)
{
  int i;
  cout<<"����� ��� "<<a.n<<" ���������� ��� �������� ��� ���������� �� ��� ������� "<<a.id<<"\n";
  for(i=0;i<a.n;i++)
    s>>a.neighbour_id[i];
  cout<<"����� �� ���������� ���� ��� ��������� \n";
  for(i=0;i<a.n;i++)
    s>>a.sinaps[i];
  cout<<"����� �� ������� ������������� ��� ��� ������� "<<a.id<<" = ?";
  s>>a.threshold;
  cout<<"����� ��� ��������� ��� ������� "<<a.id<<" = ? ";
  s>>a.state;
  return s;
}

class network{
    neuron *P;
    int n,state;
  public:
    void *operator new(size_t size);
    void operator delete(void *NW);
	 friend ostream &operator<(ostream &s, network a);
    int calk_state();

};

void *network::operator new(size_t size)
{
  network *N;

  N=(network *)malloc(size);
  cout<<"����� ��� ������ ��� �������� ��� ��������� �� ������ = ? ";
  cin>>N->n;
  N->P=new neuron[N->n];
  return N;
}

void network::operator delete(void *NW)
{
  int i;
  for(i=0;i<((network *)NW)->n; i++)
    delete(&((network*)NW)->P[i]);
  free(((network*)NW)->P);
}

ostream &operator<(ostream &s, network a)
{
  int i;
  if(a.state)
    cout<<"��������� ������� stable\n";
  else
    cout<<"��������� ������� unstable\n";
  for(i=0;i<a.n;i++)
    cout<<"��������� ������� "<<a.P[i].get_id()<<"  "<<a.P[i].get_state()<<"\n";
  return s;
}

int network::calk_state()
{
  int i,times,f,j,t,sum,ti,old,k;
  int *new_state;
  new_state=new int[n];
  cout<<"����� ��� ������� ������ ������������������ ��� ���������� ���� ������� = ? ";
  cin>>times;
  for(k=0;k<times;k++){
    f=1;
    for(i=0;i<n;i++){
    sum=0;
    t=P[i].get_n();
    old=P[i].get_state();
    for(j=0;j<t;j++){
      ti=P[i].get_neighbour(j);
      sum+=P[i].get_sinaps(j)*P[ti].get_state();
    }
    if(sum>P[i].get_threshold())
      new_state[i]=1;
    else
      new_state[i]=-1;
    if(old!=new_state[i])f=0;
  }
  if(f) break;
  for(j=0;j<n;j++)
    P[j].set_state(new_state[j]);
  }
  if(f)
    state=1;
  else
    state=0;
  delete(new_state);
  return state;
}


void main()
{ network *Net;
  Net=new network;
  Net->calk_state();
  cout<Net[0];
  delete(Net);
}