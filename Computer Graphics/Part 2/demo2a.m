function P = demo2a() % Dhlwsh ths sunarthshs demo2a xwris orismata
    %Orizw ta 4 shmeia me omogeneis suntetagmenes ws pros WCS.
    p1 = [1;2;-5;1];
    p2 = [0;1;1;1];
    p3 = [2;3;-5;1];
    p4 = [4;2;-1;1];
    th = pi/4;%orizw thn gwnia peristrofhs.
    t1 = [-2;-2;3];%orizw to dianusma metatopishs pou thelw na metatopisw ta shmeia pou exw orisei.
    t2 = [2;2;-3];%orizw dianusma metatopishs twn suntetagmenwn.
    c0 = [4;-2;4];%orizw to dianusma metatopishs gia na metatopisw thn arxh tou susthmatos suntetagmenwn sto shmeio K.
    g = [2;3;-1];%orizw to parallhlo dianusma ston axona peristrofhs.
    gnew = g/norm(g);%orizw to g ws monadiaio dianusma gia auto to diairw me to metro tou.
    R = rotmat(th,gnew);%kalw thn rotmat gia na orisw ton pinaka peristrofhs R.
    cph = [p1 p2 p3 p4]%orizw pinaka diastashs 4x4 pou perilamvanei ta 4 shmeia.
    cph = pointtrans(eye(3),cph,t1)%kalw thn sunarthsh pointtrans giati thelw na metatopisw ta shmeia kata dianusma t1.
    cph = systemtrans(eye(3),cph,c0);%kalw thn systemtrans wste na orisw tis suntetagmenes twn shmeiwn ws pros to neo susthma suntetagmenwn.
    ct = zeros(3,1);%orizw mia sthlh me mhdenika.3x1 diastasewn.
    cph =  pointtrans(R,cph,ct);%kalw thn pointtrans wste na orisw tis suntetagmenes twn shmeiwn meta tis peristrofh kata ton pinaka R.
    cph = systemtrans(eye(3),cph,-c0)%Kalw thn systemtrans wste na ekfrasw tis suntetagmenes ws pros to arxiko susthma pou apotelei to WCS.
    cph = pointtrans(eye(3),cph,t2)%kalw thn pointtrans gia na metatopisw tis suntetagmenes kata t2.
    %teleiwnei h sunarthsh kai epistrefei tis suntetagmenes meta apo tous
    %diaforous metasxhmatismous.
    
end

