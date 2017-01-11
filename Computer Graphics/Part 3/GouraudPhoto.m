function Im = GouraudPhoto(w,cv,cK,cu,bC,M,N,H,W,r,F,S,ka,kd,ks,ncoeff,Ia,IO)%Dhlwsh sunarthshs pou dhmiourgei thn egxrwmh fwtografia enos 3D antikeimenou
sizeK = size(ka,1);%Dhlwsh megethous K
sizeN = size(r,2);%Dhlwsh megethous N
Im = zeros(M,N,3);%Arxikopoihsh tou kamva
Im(:,:,1) = bC(1,1);%Arxikopoihsh tou background tou kamva se gkri
Im(:,:,2) = bC(2,1);
Im(:,:,3) = bC(3,1);
Normals = VertNormals(r,F);%Anathesi twn Normal Vectors olwn twn korufwn
ra = [r;ones(1,sizeN)];%Metatroph twn suntetagmenwn twn korufwn se omogeneis suntetagmenes
coordsToCCS = projCameraKu(w,cv,cK,cu,ra);%Euresh twn prooptikwn provolwn twn korufwn
for k = 1:size(coordsToCCS,2)
   coordsToCCS(:,k) = coordsToCCS(:,k) + [H/2;W/2];%Metatopisw twn provolwn sto kentro tou kamva
end
%Eyresh logou pixels/inches
pixx = M/H;
pixy = N/W;
%Antistoixish inches -> pixels
pixels(1,:) = round(coordsToCCS(1,:)*pixx);
pixels(2,:) = round(coordsToCCS(2,:)*pixy);
%Diadikasia eureshs tou pinaka peristrofhs R
CK = cK - cv;
cz = CK/norm(CK);
t = cu - dot(cu,cz)*cz;
cy = t/norm(t);
cx = cross(cy,cz);
R = [cx cy cz];
re = R*r;%Pollaplasiasmos tou R me tis suntetagmenes twn korufwn me skopo thn euresh twn kontinoterwn trigwnwn
for j = 1:sizeK
    pe(j) = (re(3,F(j,1))+ re(3,F(j,2)) + re(3,F(j,3)))/3;%Kentrou varous tou j trigwnou
    status(j) = j;%Pinakas pou dhlwnei thn thesi tou trigwnou j
end
%Bubblesort me skopo thn taxinomhsh twn trigwnwn me vash thn apostash tous
%apo to kentro ths kameras
length = sizeK;
while length > 0
    length2 = 0;
    for i = 2:length
        if pe(i) < pe(i-1)
        j = i-1;
        temp = pe(i);
        pe(i) = pe(j);
        pe(j) = temp;
        temp1 = F(i,:);
        F(i,:) = F(j,:);
        F(j,:) = temp1;
        temp2 = status(i);
        status(i) = status(j);
        status(j) = temp2;
        length2 = i;
        end
    end
    length = length2
end
%Euresh fwtismou gia kathe trigwno
for j = 1:sizeK
    for i = 1:3
         k = (r(:,F(j,1))+r(:,F(j,2)) + r(:,F(j,3)))/3;%Euresh tou kentrou varous tou trigwnou
         I1 = ambientLight(k,ka(status(j),:),Ia);
         I2 = diffuseLight(k,Normals(:,F(j,i)),kd(status(j),:),S,IO);
         I3 = specularLight(cv,k,Normals(:,F(j,i)),ks(status(j),:),ncoeff,S,IO);
         I(j,i,:) = (I1+I2+I3);%Euresh sunolikou fwtismou
    end
end
%Xrwmatismos tou 3D antikeimenou
for j = 1:sizeK
      V = [pixels(:,F(j,1)) pixels(:,F(j,2)) pixels(:,F(j,3))];%Kathorismos twn korufwn tou trigwnou
      %Kathorismos tou xrwmatos tou kathe trigwnou
      CV(1,:) = I(j,1,:);
      CV(2,:) = I(j,2,:);
      CV(3,:) = I(j,3,:);

      flag1 = 0;
      flag2 = 0;
      %Elegxos ama uparxei mia suntetagmenh megalyterh tou 0(entos toy kamva)
      for i = 1:size(V,1)
           for k = 1:size(V,2)
               if V(i,k) > 0
                   flag1 = 1;
               end
             end
      end
      %telos Elegxos
      %Elegxos ama yparxei mia suntetagmenh mikroterh toy M h N(entos tou kamva)
      for i = 1:size(V,1)
           for k = 1:size(V,2)
               if V(i,k) <= M && i == 1
                  flag2 = 1;
               end
               if V(i,k) <= N && i == 2
                 flag2 = 1;
               end
          end
      end
      %telos elegxos
      %Elegxos ama uparxoun shmeia ektos kamva
      for i = 1:size(V,1)
          for k = 1:size(V,2)
               while V(i,k) <= 0 && flag1 == 1%Ama einai ektos kamva apo ta arnhtika tote prostithetai mia monada kathe fora mexri na einai entos
                   V(i,k) = V(i,k) + 1;
               end
               while V(i,k) > M && flag2 == 1 && i == 1%Ama einai ektos kamva apo ta thetika afairetai mia monada kathe fora mexri na einai entos
                  V(i,k) = V(i,k) - 1;
               end
               while V(i,k) > N && flag2 == 1 && i == 2%Ama einai ektos kamva apo ta thetika afairetai mia monada kathe fora mexri na einai entos
                  V(i,k) = V(i,k) - 1;
               end
           end
       end
%Elegxos wste oi korufes na anhkoun mesa sta epitrepta oria
      if V(1,1) > 0  && V(1,1) <= M  && V(2,1) > 0  && V(2,1) <= N  && V(1,2) > 0 && V(1,2) <= M && V(2,2) > 0  && V(2,2) <= N  && V(1,3) > 0 && V(1,3) <= M && V(2,3) > 0 && V(2,3) <= N
           Im = TriPaint(Im,V,CV);%Klhsh ths tripaint gia ton xrwmatismo tou j trigwnou
      end
end
Im = Im(1:M,1:N,:);%Orizei ston Im ola ta R-G-B
Im(1:M,1,:) = Im(1:M,2,:);%Orizei sthn prwth sthlh apo pixel ish me thn deuterh sthlh 
Im(1:M,N,:) = Im(1:M,N-1,:);%Orizei sthn teleytaia sthlh apo pixel ish me thn proteleutaia sthlh
end
