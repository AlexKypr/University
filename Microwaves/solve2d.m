function er_comp = solve2d()
a = 2.286*(10^-2);
b = 1.016*(10^-2);
L = 6*(10^-2);
d = 1.5*(10^-3);
fo = 1*(10^10);
Zin1 = 4.9678 + 1i*43.9439;
Zin2 = 108.5347 + 1i*202.0158;
c0 = 3*(10^8);
fc0 = c0/(2*a);
k0 = (2*pi*fo)/c0;
beta0 = k0*sqrt(1-(fc0/fo)^2);
n0 = 377;
kc = pi/a;
Z0 = n0/(sqrt(1-(fc0/fo)^2)); 
Za1 = (-Zin1*Z0+1i*(Z0^2)*tan(beta0*(L-d)))/(-Z0 + 1i*Zin1*tan(beta0*(L-d)));
Za2 = (-Zin2*Z0+1i*(Z0^2)*tan(beta0*(L-2*d)))/(-Z0 + 1i*Zin2*tan(beta0*(L-2*d)));
x = atanh(sqrt(2*(Za1/Za2)-1));
er = ((imag(x)/d)^2 + kc^2)/(k0^2);
beta = sqrt((k0^2)*er - (kc)^2);
tand = (real(x)*2*beta)/(d*((k0^2)*er));
er_comp = [er tand];



