function P = askhsh(N)
f0 = (10)^9;
Z0 = 50;
L1=0.2;
L2=0.13;
L3=0.1;
constC = 1/(2*pi*2*10^(-12));
RL=100;
j=1;
for f=0:(4*f0/N):(4*f0)
    XL = -constC*(1/f);
    ZL = RL + (1i*XL);
    ZA = Z0*((ZL+(1i*Z0)*tan(2*pi*(f/f0)*L1))/(Z0+(1i*ZL)*tan(2*pi*(f/f0)*L1)));
    YA = 1/ZA;
    Zklad = (1i*Z0)*tan(2*pi*L2*(f/f0));
    Yklad = 1/Zklad;
    YB = YA + Yklad;
    ZB = 1/YB;
    ZC = Z0*((ZB+(1i*Z0)*tan(2*pi*(f/f0)*L3))/(Z0 +(1i*ZB)*tan(2*pi*(f/f0)*L3)));
    YC=1/ZC;
    Ycap = (1i*2*pi*f*2.7*(10^(-12)));
    Yin = Ycap + YC;
    Zin = 1/Yin;
    G(j) = abs((Zin-Z0)/(Zin+Z0));
    lG(j) = 20*log10(G(j));
    j = j+1;
end;

f=0:(4*f0/N):4*f0;
figure;
plot(f,G);
grid;
xlabel('Frequency');
ylabel('Reflection Coefficient');

f=0:(4*f0/N):4*f0;
figure;
plot(f,lG);
grid;
xlabel('Frequency');
ylabel('Reflection Coefficient(dB)');


