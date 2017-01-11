function I = diffuseLight(P,N,kd,S,IO)%Sunarthsh pou upologizei to fwtismo logw diaxuths anaklashs
N = N/norm(N);%Kanonikopoihsh tou kathetou dianusmatos N wste na einai monadiaio
sizeS = size(S);%Upologismos tou megethos tou pinaka twn suntetagmenwn
I = zeros(1,3);%Arxikopoihsh tou pinaka I
kd = kd/255;%Kanonikopoihsh tou dianusmatow kd wste na anhkei sto [0,1]
for i = 1:sizeS(2)%Arxikopoihsh epanalhpshs gia ton upologismo tou fwtismou gia oles tis phges
   L(:,i) = S(:,i) - P;%Upologismos dianusmatos L
   L(:,i) = L(:,i)/norm(L(:,i));%Kanonikopoihsh dianusmatos L
   med = dot(N,L(:,i));%Eswteriko ginomeno dianusmatwn N*L
   checkI = ((IO(i,:)*(med)).*kd);%Upologismos parastashs wste na ypologistei o fwtismos
   if checkI < 0 %elegxw ama o fwtismos me vash thn phgh i einai arnhtikos wste na ton thesw iso me to [0,0,0]
       checkI = zeros(1,3);
   end
   I = I + checkI;%Athroistikos upologismos fwtismou apo tis diafores phges
end
end

