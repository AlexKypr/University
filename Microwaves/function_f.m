function [ Average ] = function_f(p)
d1 = p(1);
d2 = p(2);
d3 = p(3);
l1 = p(4);
l2 = p(5);
l3 = p(6);
Z0 = 50;
ZL = 200-1j*50;
k=1;
S=0;
for normf =0.01:0.01:2
bl = (2*pi)*normf ;
Z1 = Z0*(ZL + Z0*tan(d1*bl))/(Z0+ZL*tan(d1*bl));
Zop1 = -1j*Z0*cot( l1*bl);
Z2 = (Z1*Zop1)/(Z1+Zop1);
Z3 = Z0*(Z2+Z0*tan(d2*bl))/(Z0+Z2*tan(d2*bl));
Zop2 = -1j*Z0*cot(l2*bl);
Z4 = (Z3*Zop2)/(Z3+Zop2);
Z5 = Z0*(Z4+Z0*tan(d3*bl))/(Z0+Z4*tan(d3*bl));
Zop3 = -1j*Z0*cot(l3*bl);
Zeq = (Z5*Zop3)/(Z5+Zop3);
Gin(k) = norm((Zeq-50)/(Zeq+50));
S=S+Gin(k);
k = k +1;
end
Average = S/101;
figure;
f=0.01:0.01:2;
plot(f,Gin);
grid;
xlabel( 'normf' );
ylabel( 'Reflection Coefficient' );
end