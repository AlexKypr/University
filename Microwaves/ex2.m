function Q = askhsh(N)
Z0=50;
Z1=101.6;
Z2=Z1;
Zklad1=98.45;
Zklad2=43.6;
Zklad3=Zklad1;
f0 = 10^9;
j=1;
for f=0:((3*f0)/N):(3*f0);
    Y1 = 1/Z0;
    Zinklad1 = (-1i)*Zklad1*cot(2*pi*(f/f0)*(1/8));%o prwtos kladwths
    Yinklad1 = 1/Zinklad1;
    Yin1 = Y1 + Yinklad1;%h Yin meta ton prwto kladwth
    Zin1 = 1/Yin1;
    Zin2 = Z1*((Zin1+(1i)*Z1*tan(2*pi*(f/f0)*(1/8)))/(Z1+(1i)*Zin1*tan(2*pi*(f/f0)*(1/8))));%h Zin prin ton 2o kladwth
    Yin2 = 1/Zin2;
    Zinklad2 = (-1i)*Zklad2*cot(2*pi*(f/f0)*(1/8));%o 2os kladwths
    Yinklad2 = 1/Zinklad2;
    Yin3 = Yinklad2 + Yin2;%H Yin meta ton kladwth
    Zin3 = 1/Yin3;
    Zin4 = Z2*((Zin3+(1i)*Z2*tan(2*pi*(f/f0)*(1/8)))/(Z2+(1i)*Zin3*tan(2*pi*(f/f0)*(1/8))));
    Yin4 = 1/Zin4;%h Yin prin ton teleutaio kladwth
    Zinklad3 = (-1i)*Zklad3*cot(2*pi*(f/f0)*(1/8));%o 3os kladwths
    Yinklad3 = 1/Zinklad3;
    Yintot = Yinklad3 + Yin4;
    Zintot = 1/Yintot;
    G(j) = (Zintot - Z0)/(Zintot+Z0);
    lG(j) = 20*log10(G(j));
    if lG(j) < -40
        lG(j) = -40;
    end
    SWR(j) = (1+abs(G(j)))/(1-abs(G(j)));
    if SWR(j) > 10
        SWR(j) = 10;
    end
    
    j = j+1;
end

f=0:(3*f0/N):3*f0;
figure;
plot(f,lG);
grid;
xlabel('Frequency');
ylabel('Reflection Coefficient(dB)');

f=0:(3*f0/N):3*f0;
figure;
plot(f,SWR);
grid;
xlabel('Frequency');
ylabel('SWR');

