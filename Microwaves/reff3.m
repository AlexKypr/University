function [ y ] = reff3( p )
z0=50;
zl=200-j*50;
normf=(0.01:0.01:2);
b=2*pi*normf;


zopen1=-j*z0*cot(b*p(4));
zopen2=-j*z0*cot(b*p(5));
zopen3=-j*z0*cot(b*p(6));
yopen1=1./zopen1;
yopen2=1./zopen2;
yopen3=1./zopen3;

z1=z0*(zl+j*z0*tan(b*p(1)))./(z0+j*zl.*tan(b*p(1)));
y1=1./z1;
y2=yopen1+y1;
z2=1./y2;
z3=z0*(z2+j*z0*tan(b*p(2)))./(z0+j*z2.*tan(b*p(2)));
y3=1./z3;
y4=yopen2+y3;
z4=1./y4;
z5=z0*(z4+j*z0*tan(b*p(3)))./(z0+j*z4.*tan(b*p(3)));
y5=1./z5;
yin=yopen3+y5;
zin=1./yin;
S11=(zin-z0)./(zin+z0);
nS11=abs(S11);

y=mean(nS11);

normf = 0.01:0.01:2;
figure;
plot(normf,nS11);
grid;
xlabel('Normf');
ylabel('Reflection Coefficient');



end

