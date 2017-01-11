function fil = filtere()
Ze1 = 63.54;
Zo1 = 41.38;
Ze2 = 51.8;
Zo2 = 48.39;
Ze3 = 51.8;
Zo3 = 48.39;
Ze4 = 63.54;
Zo4 = 41.38;
ZL = 50;
fo = 3.2*(10^9);
fstart = 2.4*(10^9);
fend = 4*(10^9);
N = 100;
j = 1;
for f = fstart:((fend-fstart)/N):(fend)
bl = 0.25*(2*pi)*(f/fo);
A = [((Ze1 + Zo1)*(exp(1i*2*bl)+1))/(2*exp(1i*bl)*(Ze1-Zo1))  ((((Ze1+Zo1)*(1+exp(1i*2*bl)))^2)-(4*exp(1i*2*bl)*(Ze1-Zo1)^2))/(4*exp(1i*bl)*(exp(1i*2*bl)-1)*(Ze1-Zo1));
     (exp(1i*2*bl)-1)/(exp(1i*bl)*(Ze1-Zo1)) ((Ze1+Zo1)*(1+ exp(1i*2*bl)))/(2*(Ze1-Zo1)*exp(1i*bl))
]; 
B = [((Ze2 + Zo2)*(exp(1i*2*bl)+1))/(2*exp(1i*bl)*(Ze2-Zo2))  ((((Ze2+Zo2)*(1+exp(1i*2*bl)))^2)-(4*exp(1i*2*bl)*(Ze2-Zo2)^2))/(4*exp(1i*bl)*(exp(1i*2*bl)-1)*(Ze2-Zo2));
     (exp(1i*2*bl)-1)/(exp(1i*bl)*(Ze2-Zo2)) ((Ze2+Zo2)*(1+ exp(1i*2*bl)))/(2*(Ze2-Zo2)*exp(1i*bl))
]; 
C = [((Ze3 + Zo3)*(exp(1i*2*bl)+1))/(2*exp(1i*bl)*(Ze3-Zo3))  ((((Ze3+Zo3)*(1+exp(1i*2*bl)))^2)-(4*exp(1i*2*bl)*(Ze3-Zo3)^2))/(4*exp(1i*bl)*(exp(1i*2*bl)-1)*(Ze3-Zo3));
     (exp(1i*2*bl)-1)/(exp(1i*bl)*(Ze3-Zo3)) ((Ze3+Zo3)*(1+ exp(1i*2*bl)))/(2*(Ze3-Zo3)*exp(1i*bl))
]; 
D = [((Ze4 + Zo4)*(exp(1i*2*bl)+1))/(2*exp(1i*bl)*(Ze4-Zo4))  ((((Ze4+Zo4)*(1+exp(1i*2*bl)))^2)-(4*exp(1i*2*bl)*(Ze4-Zo4)^2))/(4*exp(1i*bl)*(exp(1i*2*bl)-1)*(Ze4-Zo4));
     (exp(1i*2*bl)-1)/(exp(1i*bl)*(Ze4-Zo4)) ((Ze4+Zo4)*(1+ exp(1i*2*bl)))/(2*(Ze4-Zo4)*exp(1i*bl))
]; 
 

F = A*B*C*D;

Zin = (F(1,1)*ZL + F(1,2))/(F(2,1)*ZL + F(2,2))
G(j) = norm((Zin - ZL)/(Zin + ZL));
lG(j) = 20*log10(G(j));
    if lG(j) < -40
     lG(j) = -40;
    end
    j = j + 1;
end

figure;
f = fstart:((fend-fstart)/N):(fend);
plot(f,lG);
grid;
xlabel('Frequency');
ylabel('Reflection Coefficient(dB)');

    
