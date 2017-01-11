function I = Painter( Q,T,CV,M,N )%h sunarthsh pou dexetai ws orismata tous pinakes pou orisame sthn colordemo kai epistrefei ton pinaka diastashs MxNx3
dimensionT = size(T);%swzw se vector tis diastaseis tou pinaka T
dimensionQ = size(Q);%swzw se vector tis diastaseis tou pinaka Q
dimensionCV = size(CV);%swzw se vector tis diastaseis tou pinaka CV
X = ones(M,N,3);%arxikopoiw ton pinaka X me assous(Thelw leuko background)
Cv = ones(3,3);%arxikopoiw ton pinaka Cv pou tha xrhsimopoihsw gia na dialexw ta xrwmata twn korufwn pou epithumw
for i = 1:1:dimensionQ(2)%Diatrexw tous arithmous poy dhlwnoun se poia korufh(index apo pinakes) eimaste
    V = zeros(2,3);%Arxikopoiw ton V, pou tha xrhsimopoihthei gia na apothikeusw tis suntetagmenes twn korufwn tou ekastwte trigwnou
    %Thetw times ston V 2x3 tis antistoixes times apo ton pinaka T
    %epilegontas tis theseis me vash ton pinaka Q.
    %Thewrhsa tis suntetagmenes ths prwths sthlhs tou T ws tetagmenes kai
    %thn deuterh sthlh ws tetmhmenes.
    V(1,1) = T(Q(i,1),2);
    V(2,1) = T(Q(i,1),1);
    V(1,2) = T(Q(i,2),2);
    V(2,2) = T(Q(i,2),1);
    V(1,3) = T(Q(i,3),2);
    V(2,3) = T(Q(i,3),1);
    %Thetw times ston Cv tis antistoixes tou CV me vash ton pinaka Q.
    Cv(1,1) = CV(Q(i,1),1);
    Cv(1,2) = CV(Q(i,1),2);
    Cv(1,3) = CV(Q(i,1),3);
    Cv(2,1) = CV(Q(i,2),1);
    Cv(2,2) = CV(Q(i,2),2);
    Cv(2,3) = CV(Q(i,2),3);
    Cv(3,1) = CV(Q(i,3),1);
    Cv(3,2) = CV(Q(i,3),2);
    Cv(3,3) = CV(Q(i,3),3);
    %kalw thn sunarthsh TriPaint kai apothikeuw ston X tis allages pou
    %ginontai wste sto telos na exoume ena oloklhrwmeno apotelesma kai na
    %mhn xanontai oi times tou.
    X = TriPaint(X,V,Cv);%H sunarthsh plhrwshs kai sxediasmou enos trigwnou.
    imshow(X);
end

I = X;%Pernaw ws telikh timh sto I ton X kai epistrefei to apotelesma sthn colordemo wste na to provaloume.
end

