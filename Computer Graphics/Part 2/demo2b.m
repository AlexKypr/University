function R = demo2b()%Dhlwsh sunarthshs demo2b() xwris orismata.
   [P,F] = readplg('stanford_bunny.plg.txt');%Dexomai ws orisma to montelo pou tha anaparistw kai diavazw ta dedomena ta opoia to sunthetoun.
   dimensionP = size(P);%Vriskw tis diastaseis tou pinaka P.
   t1 = [-2;-2;3];%Orizw ton pinaka metatopishs t1.
   t2 = [2;2;-3];%orizw ton pinaka metatopishs t2.
   g = [2;3;-1];%Dianusma parallhlo ston axona peristrofhs.
   gnew = g/norm(g);%Orizw to monadiaio dianusma g.
   th = pi/4;%H gwnia ths peristrofhs.
   c0 = [4;-2;4];%Orizw to dianusma metatopishs wste na metatopisw to susthma suntetagmenwn sto shmeio K.
   R = rotmat(th,gnew);%Kalw thn sunarthsh rotmat wste na vrw ton pinaka peristrofhs.
   addrow = ones(1,dimensionP(2));%dhmiourgw mia grammh diastasewn 1xN me assous.
   P = [P;addrow];%prosthetw mia grammh sto telos tou pinaka P diastasewn 1xN,epeidh thelw na einai se omogeneis suntetagmenes.
   plotplg(P,F);%provallw tis suntetagmenes tou montelou prin apo kapoion metasxhmatismo.
   hold on %diathrw thn provolh wste opoia allh kanw na diathrhsei thn arxikh gia na mporw na tis sugkrinw.
   res = pointtrans(eye(3),P,t1);%Kalw thn sunarthsh pointtrans wste na metatopisw to montelo kata dianusma t1.
   plotplg(res,F);%provallw tis suntetagmenes tou montelou meta ton prwto metasxhmatismo.
   hold on %diathrw thn provolh.
   res = systemtrans(eye(3),res,c0);%Kalw thn sunarthsh systemtrans wste na ekfrasw tis suntetagmenes tou montelou ws pros to neo susthma suntetagmenwn pou prokuptei apo thn metatopish kata c0.
   ct = zeros(3,1);%orizw sthlh me mhdenika diastashs 3x1.
   res =  pointtrans(R,res,ct);%kalw thn sunarthsh pointtrans me skopo thn peristrofh tou montelou me vash ton pinaka peristrofhs.
   res = systemtrans(eye(3),res,-c0);%kalw thn sunarthsh systemtrans wste na ekfrasw to montelo ws pros to arxiko susthma suntetagmenwn.
   plotplg(res,F);%provallw tis suntetagmenes tou montelou meta apo ton deutero metasxhmatismo.
   hold on %diathrw thn provolh.
   res = pointtrans(eye(3),res,t2);%kalw thn sunarthsh pointtrans wste na metatopisw to montelo kata dianusma t2.
   plotplg(res,F);%provallw tis suntetagmenes tou montelou meta apo ton trito metasxhmatismo.
end

