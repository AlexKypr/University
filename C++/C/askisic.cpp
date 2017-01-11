#include <dos.h>
#include <iostream.h>
#include <process.h>
#include <alloc.h>
class data{
    int n;
    float *G_zone_prices,*G_taxco;
    float *B_zone_prices,*B_taxco;
    float tree_farming,poa_farming,S_c;

  public:
    data();
    float G_get_zon_price(int z){return G_zone_prices[z];}
    float G_get_tax_c(int z){return G_taxco[z];}
    float B_get_zon_price(int z){return B_zone_prices[z];}
    float B_get_tax_c(int z){return B_taxco[z];}
    float get_tree_farming(){return tree_farming;}
    float get_poa_farming(){return poa_farming;}
    float get_S_c(){return S_c;}
    int get_n(){return n;}
    ~data();
}D;

data::data()
{
  cout<<"����� ��� ������ ��� ����� = ? ";
  cin>>n;
  if((G_zone_prices=(float *)malloc(n*sizeof(float)))==NULL){
    cout<<"��� ������� ������ ��������� ����� (���� 1)\n";
    exit(1);
  }
  if((B_zone_prices=(float *)malloc(n*sizeof(float)))==NULL){
    cout<<"��� ������� ������ ��������� ����� (���� 2)\n";
    exit(1);
  }
  if((G_taxco=(float *)malloc(n*sizeof(float)))==NULL){
    cout<<"��� ������� ������ ��������� ����� (���� 3)\n";
    exit(1);
  }
  if((B_taxco=(float *)malloc(n*sizeof(float)))==NULL){
    cout<<"��� ������� ������ ��������� ����� (���� 3)\n";
    exit(1);
  }
  int i;
  for(i=0;i<n;i++){
    cout<<"��� �� ���� "<<i<<" �����\n";
    if(i){
      cout<<"��� ���� ����� ��� �� �������� = ? ";
      cin>>G_zone_prices[i];
      cout<<"��� ���������� ����������� ��� �� �������� = ";
      cin>>G_taxco[i];
    }
    cout<<"��� ���� ����� ��� �� ������ = ? ";
    cin>>B_zone_prices[i];
    cout<<"��� ���������� ����������� ��� �� ������ = ";
    cin>>B_taxco[i];
  }
  cout<<"����� ��� ���������� ����������� ��� ��� ������������ ������� = ? ";
  cin>>tree_farming;
  cout<<"����� ��� ���������� ����������� ��� ��� ������� ������������ = ? ";
  cin>>poa_farming;
  cout<<"����� ��� ���������� ����������� ��� �������� = ? ";
  cin>>S_c;
}
data::~data()
{
  free(G_zone_prices);
  free(G_taxco);
  free(B_zone_prices);
  free (B_taxco);
}

class ground{
   float area,zone_price,tax_c,tax;
   int zone;
  public:
    ground(int z,float ar);
    ground(float ar,int t);
    float get_tax();
};
ground::ground(int z,float ar)
{
  zone=z;
  area=ar;
  zone_price=D.G_get_zon_price(zone);
  tax_c=D.G_get_tax_c(zone);
}

ground::ground(float ar,int t)
{
  zone=0;
  if(t==1)tax_c=D.get_tree_farming();
  if(t==2)tax_c=D.get_poa_farming();
  area=ar;
}

float ground::get_tax()
{
  if(zone==0)
    tax=area*tax_c;
  else
    tax=area*zone_price*tax_c;
  return tax;
}

class building{
    float area,tax_c,zone_price,tax;
    int flat,zone;
  public:
    building(int z,float ar);
    building(int z,float ar,int fl);
    float get_tax();
};

building::building(int z,float ar,int fl)
{
  area=ar;
  zone=z;
  flat=fl;
  zone_price=D.B_get_zon_price(zone);
  tax_c=D.B_get_tax_c(zone);
}
building::building(int z,float ar)
{
  flat=0;
  area=ar;
  zone=z;
  zone_price=D.B_get_zon_price(zone);
  tax_c=D.B_get_tax_c(zone);
}

float building::get_tax()
{
  if(flat==0)
    tax=area*tax_c*zone_price*D.get_S_c();
  else
    tax=flat*area*tax_c*zone_price;
  return tax;
}

class property:private ground, private building{
    float tax;
  public:
   
    property(int z,float g_ar,float b_ar,int fl);
    property(int z,float g_ar,float b_ar);
    property(int z,int fl,float g_ar,float b_ar,int t);
    property(int z,int t,float g_ar,float b_ar);

    float get_ptax();
};

property::property(int z,float g_ar,float b_ar,int fl):ground(z,g_ar),building(z,b_ar,fl){}
property::property(int z,float g_ar,float b_ar):ground(z,g_ar),building(z,b_ar){}
property::property(int z,int fl,float g_ar,float b_ar,int t):ground(g_ar,t),building(z,b_ar,fl){}
property::property(int z,int t,float g_ar,float b_ar):ground(g_ar,t),building(z,b_ar){}

float property::get_ptax()
{
  tax=ground::get_tax()+building::get_tax();
  return tax;
}                                       

void main()
{
  struct date d;
  int year,month,day,zone,ch,fl,t;
  long e_date,c_date;
  float g_ar,b_ar,tax,tax_sum=0;
  cout<<"\n����� �� ���� ����������� �� ��������� = ? ";
  cin>>year;
  cout<<"����� ��� ���� ����������� �� ��������� = ? ";
  cin>>month;
  cout<<"����� ��� ����� ����������� �� ��������� = ? ";
  cin>>day; 
  e_date=(long)year*10000+month*100+day;
  int i;
  for(i=0;i<4;i++){
    getdate(&d);
    c_date=(long)d.da_year*10000+d.da_mon*100+d.da_day;
    if(c_date>e_date)break;
    
    cout<<"\n����� 1 �� � ���������� ����������� ��� �������� ��� ��������\n";
    cout<<"����� 2 �� � ���������� ����������� ��� �������� ��� �������\n";
    cout<<"����� 3 �� � ���������� ����������� ��� ����������� ��� ��������\n";
    cout<<"����� 4 �� � ���������� ����������� ��� ����������� ��� ��������\n";
    cin>>ch;
    if(ch<1||ch>4){
      cout<<"����� �������\n";
      continue;
    }
     
    if(ch==1){
      cout<<"\n����� �� ���� ���� ����� ��������� � ���������� (����� 0 ��� "<<D.get_n()-1<<") = ? ";
      cin>>zone;
      cout<<"����� �� ������� ��� ��������� = ? ";
      cin>>g_ar;
      cout<<"����� �� ������� ��� ���������  = ? ";
      cin>>b_ar;
      cout<<"����� ��� ������ ��� ������ = ? ";
      cin>>fl;
      property P(zone,g_ar,b_ar,fl);
      tax=P.get_ptax();
    }
    if(ch==2){
      cout<<"\n����� �� ���� ���� ����� ��������� � ���������� (����� 0 ��� "<<D.get_n()-1<<") = ? ";
      cin>>zone;
      cout<<"����� �� ������� ��� ��������� = ? ";
      cin>>g_ar;
      cout<<"����� �� ������� ��� ��������   = ? ";
      cin>>b_ar;
      property P(zone,g_ar,b_ar);
      tax=P.get_ptax();
    }
    if(ch==3){
      zone=0;
      cout<<"\n����� �� ������� ��� ������������  = ? ";
      cin>>g_ar;
      cout<<"����� �� ������� ��� ���������  = ? ";
      cin>>b_ar;
      cout<<"����� ��� ������ ��� ������ = ? ";
      cin>>fl;
      cout<<"����� ��� ���� ��� ������������ (1 ��� ����������������� 2 ��� ������ �����������) = ? ";
       cin>>t;
      property P(zone,fl,g_ar,b_ar,t);
      tax=P.get_ptax();
    }
    if(ch==4){
      zone=0;
      cout<<"\n����� �� ������� ��� ������������  = ? ";
      cin>>g_ar;
      cout<<"����� �� ������� ��� ��������  = ? ";
      cin>>b_ar;
      cout<<"����� ��� ���� ��� ������������ (1 ��� ����������������� 2 ��� ������ �����������) = ? ";
      cin>>t;
      property P(zone,t,g_ar,b_ar);
      tax=P.get_ptax();
    }
    tax_sum+=tax;
    cout<<"\n����������� �����      "<<tax<<"\n";
  }
  cout<<"��������� ����� ��� �� ����������    "<<tax_sum<<"\n";
}










