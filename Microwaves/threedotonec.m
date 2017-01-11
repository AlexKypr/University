function [ average ] = threedotonec( p )
d1 = p(1);
d2 = p(2);
d3 = p(3);
l1 = p(4);
l2 = p(5);
l3 = p(6);
Zl = 5 + 1i*10;
Zo = 50;
Sum = 0;
j = 1;
for normf = 0.01:0.01:2
  betal = 2*pi*normf;
  Zind1 = Zo*((Zl + 1i*Zo*tan(betal*d1))/(Zo + 1i*Zl*tan(betal*d1)));
  Zinl1 = -1i*Zo*cot(betal*l1);
  Yind1 = 1/Zind1;
  Yinl1 = 1/Zinl1;
  Yin1 = Yind1 + Yinl1;
  Zin1 = 1/Yin1;
  Zind2 = Zo*((Zin1 + 1i*Zo*tan(betal*d2))/(Zo + 1i*Zin1*tan(betal*d2)));
  Zinl2 = -1i*Zo*cot(betal*l2);
  Yind2 = 1/Zind2;
  Yinl2 = 1/Zinl2;
  Yin2 = Yind2 + Yinl2;
  Zin2 = 1/Yin2;
  Zind3 = Zo*((Zin2 + 1i*Zo*tan(betal*d3))/(Zo + 1i*Zin2*tan(betal*d3)));
  Zinl3 = -1i*Zo*cot(betal*l3);
  Yind3 = 1/Zind3;
  Yinl3 = 1/Zinl3;
  Yin3 = Yind3 + Yinl3;
  ZinFinal = 1/Yin3;
  G(j) = norm((ZinFinal - Zo)/(ZinFinal + Zo));
  Sum = Sum + G(j);
  j = j + 1;
end
average = Sum/(j-1);


normf = 0.01:0.01:2;
figure;
plot(normf,G);
grid;
xlabel('Normf');
ylabel('Reflection Coefficient');

end






