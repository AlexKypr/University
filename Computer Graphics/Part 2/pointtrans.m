function cqh = pointtrans(L,cph,ct)%Dhlwsh sunarthshs me orismata L pinakas metasxhmatismou,cph oi suntetagmenes pou theloume na metasxhmatisoume kai ct o pinakas metatopishs
    dimensionL = size(L);%megethos pinaka L.
    Lh = [L ct];%orizoume neo pinaka matrix me epipleon sthlh ton 3x1 pinaka ct.
    zero = zeros(1,dimensionL(2));%orizoume pinaka apo mhdenika diastashs 1xN.
    lastrow = [zero 1];%orizoume pinaka diastashs 1x(N+1) me N mhdenika kai 1 asso.
    Lh = [Lh;lastrow];%orizoume neo pinaka metasxhmatismou L.Anw meros diastash 3x(N+1) kai katw meros 1x(N+1) sunolika 4x(N+1) epeidh exoume omogeneis suntetagmenes.
    cqh = Lh*cph;%Kalw thn vectrans gia na pollaplasiasw ton pinaka L me tis suntetagmenes cph.
    %Kai epistrefei tis suntetagmenes cqh,pou exoun metasxhmatistei me
    %shmeiako affine.
end

