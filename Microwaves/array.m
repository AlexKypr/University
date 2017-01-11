function f = arra()
syms Ze Zo l b


A = [1 1 1 1;
    1 1 -1 -1;
    exp(-1i*b*l) exp(1i*b*l) exp(-1i*b*l) exp(1i*b*l);
    exp(-1i*b*l) exp(1i*b*l) -exp(-1i*b*l) -exp(1i*b*l)];

B = [1/Ze -1/Ze 1/Zo -1/Zo;
     1/Ze -1/Ze -1/Zo 1/Zo;
    (1/Ze)*exp(-1i*b*l) -(1/Ze)*exp(1i*b*l) (1/Zo)*exp(-1i*b*l) -(1/Zo)*exp(1i*b*l);
    (1/Ze)*exp(-1i*b*l) -(1/Ze)*exp(1i*b*l) -(1/Zo)*exp(-1i*b*l) (1/Zo)*exp(1i*b*l)];

Z = A*inv(B);
Z1 = simplify(Z);
pretty(Z1)
