function dph = systemtrans(L,cph,c0)%Dhlwsh sunarthshs me orismata L pinaka metasxhmatismou,cph oi suntetagmenes pou theloume na metasxhmatisoume kai c0 to dianusma metatopishs.
    dimension = size(L);%megethos pinaka L.
    Lh = L\eye(3);%Xrhsimopoieitai o telesths \ giati einai pio grhgoros kai axiopistos apo ton inv(L)*eye(3).
    Lh = [Lh -L\c0];%orizoume neo pinaka apo ton L kai prosthetoume mia sthlh me timh -L\c0 megethous 3x1.
    zero = zeros(1,dimension(2));%orizoume mia grammh mhdenikwn diastashs 1xN.
    lastrow = [zero 1];%orizoume mia grammh me diastashs 1x(N+1) me N mhdenika kai 1 asso.
    Lh = [Lh;lastrow];%orizoume pinaka pou apoteleitai apo ton Lh sto anw meros kai tou prostithetai ws teleutaia grammh h lastrow.
    dph = Lh*cph;%kaloume thn sunarthsh vectrans wste na pollaplasiasoume tous pinakes Lh me tis suntetagmenes cph.
    %Epistrefei tis dph suntetagmenes pou exoun metasxhmatistei se neo
    %susthma suntetagmenwn.
end

