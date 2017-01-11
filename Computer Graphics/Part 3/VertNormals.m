function Normals = VertNormals(r,F)%Dhlwsh sunarthshs pou upologizei to katheto dianusma gia kathe korufh tou antikeimenou
sizeR = size(r,2);%Ypologismos tou plithous twn korufwn
sizeF = size(F,1);%Ypologismos tou plithous twn trigwnwn
count = 0;
sumN = 0;
for i = 1:sizeR%Epanalhpsh me skopo thn euresh twn kathetwn dianusmatwn
    for j = 1:sizeF
        if F(j,1) == i || F(j,2) == i || F(j,3) == i%Elegxos ama kapoia korufh tou F einai ish me to i 
            count = count + 1;%Auxhsh tou metrhth Normal Vector mias korufhs
            AB = r(:,F(j,2))-r(:,F(j,1));%Euresh tou dianusmatos AB
            AC = r(:,F(j,3)) - r(:,F(j,1));%Euresh tou dianusmatos AC
            N = cross(AB,AC);%Euresh tou kathetou dianusmatos N me thn xrhsh exwterikou ginomenou
            N = N/norm(N);%Kanonikopoihsh tou dianusmatos N
            sumN = sumN + N;%Athroisma twn Normal Vectors mias korufhs
        end
    end
    meanN = sumN/count;%Mesos oros Normal Vectors
    meanN = meanN/norm(meanN);%Kanonikopoihsh telikou Normal Vector
    Normals(:,i) = meanN;%Anathesi timhs ston pinaka pou tha epistrepsei h sunarthsh
    sumN = 0;
    count = 0;
end


end

