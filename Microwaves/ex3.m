function P = askhsh3(N)
V1 = 1;
Z0 = 50;
Zc = sqrt(2)*Z0;
f0 = 5*(10^9);
ba = pi/2;
bb = pi/2;
bc = 3*pi/2;
bd = pi/2;

syms I2out I3out I4out V2 V3 V4 Iin Iain Ibin Icin Idin Iaout Ibout Icout Idout  
j=1;
for f=(f0/2):(f0/N):(3/2)*f0
    cosx1 = cos(ba*(f/f0));
    sinx1 = sin(ba*(f/f0));
    cosx2 = cos(bb*(f/f0));
    sinx2 = sin(bb*(f/f0));
    cosx3 = cos(bc*(f/f0));
    sinx3 = sin(bc*(f/f0));
    cosx4 = cos(bd*(f/f0));
    sinx4 = sin(bd*(f/f0));
    
    eqn1 = I2out*Z0 - V2 == 0;
    eqn2 = I3out*Z0 - V3 == 0;
    eqn3 = I4out*Z0 - V4 == 0;
    eqn4 = Iin + Idout - Iain == 0;
    eqn5 = Iaout - I3out - Ibin == 0;
    eqn6 = Ibout - I4out - Icin == 0;
    eqn7 = Icout - I2out - Idin == 0;
    eqn8 = V1 - cosx1*V3 - (1i)*Zc*sinx1*Iaout == 0;%εμφανίζει υπόλοιπο επειδή ο όρος V1 είναι σταθερός
    eqn9 = Iain - (1i)*(1/Zc)*sinx1*V3 - cosx1*Iaout == 0;
    eqn10 = V3 - cosx2*V4 - (1i)*Zc*sinx2*Ibout == 0;
    eqn11 = Ibin - (1i)*(1/Zc)*sinx2*V4 - cosx2*Ibout == 0;
    eqn12 = V4 - cosx3*V2 - (1i)*Zc*sinx3*Icout == 0;
    eqn13 = Icin - (1i)*(1/Zc)*sinx3*V2 - cosx3*Icout == 0;
    eqn14 = V2 - cosx4*V1 - (1i)*Zc*sinx4*Idout == 0;%εμφανίζει υπόλοιπο καθώς ο όρος cosx4*V1 είναι σταθερός
    eqn15 = Idin - (1i)*(1/Zc)*sinx4*V1 - cosx4*Idout == 0;%εμφανίζει υπόλοιπο καθώς ο όρος (1i)*(1/Zc)*sinx4*V1 είναι σταθερός
    [A,B] = equationsToMatrix([eqn1,eqn2,eqn3,eqn4,eqn5,eqn6,eqn7,eqn8,eqn9,eqn10,eqn11,eqn12,eqn13,eqn14,eqn15],[I2out,I3out,I4out,V2,V3,V4,Iin,Iain,Ibin,Icin,Idin,Iaout,Ibout,Icout,Idout]);
    X = linsolve(A,B);
    Zin(j) = V1/X(7,1);
    G(j) = abs((Zin(j) - Z0)/(Zin(j) + Z0));
    lG(j) = 20*log10(G(j));
    if (lG(j)<-40)
        lG(j) = -40;
    end
    Pin(j) = (1/2)*real(V1*conj(X(7,1)));
    Pout2(j) = (1/2)*real(X(4,1)*conj(X(1,1)));
    Pout3(j) = (1/2)*real(X(5,1)*conj(X(2,1)));
    Pout4(j) = (1/2)*real(X(6,1)*conj(X(3,1)));
    j = j + 1;
end

f=(f0/2):(f0/N):(3/2)*f0;
figure;
plot(f,Pin,'r');
hold on
plot(f,Pout2,'g')
hold on
plot(f,Pout3,'m');
hold on
plot(f,Pout4,'b');
grid;
xlabel('Frequency');
ylabel('Power');


figure;
plot(f,lG);
grid;
xlabel('Frequency');
ylabel('Reflection Coefficient');





