function I = specularLight(V,P,N,ks,ncoeff,S,IO)%Orismos sunarthshs pou upologizei ton fwtismo logw katoptrikhs anaklashs
N = N/norm(N);%Kanonikopoihsh kathetou dianusmatos
Vp = V - P;%Upologismos dianusmatos V
Vp = Vp/norm(Vp);%Kanonikopoihsh dianusmatos V
sizeS = size(S);%Upologismos megethous pinaka S
I = zeros(1,3);%Arxikopoihsh I
ks = ks/255;%Kanonikopoihsh dianusmatos ks wste na anhkei sto [0,1]
for i = 1:sizeS(2)%Ekkinhsh epanalhpsh wste na upologistei o fwtismos apo oles tis phges
   L(:,i) = S(:,i) - P;%Upologismos dianusmatos L
   L(:,i) = L(:,i)/norm(L(:,i));%Kanonikopoihsh dianusmatos L
   med = dot((2*N*dot(N,L(:,i))-L(:,i)),Vp)^ncoeff;%Upologismos eswterikou ginomenou dianusmatos
   checkI = IO(i,:)*med.*ks;%Upologismos fwtismou I gia thn i phgh
   if checkI < 0 %Elegxos ama o fwtismos I apo thn phgh i einai arnhtikos wste na ton thesw iso me 0
       checkI = zeros(1,3);
   end
   I = I + checkI;%Upologismos sunolikou fwtismou I
end
end

