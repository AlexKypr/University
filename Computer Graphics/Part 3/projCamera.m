function P = projCamera(w,cv,cx,cy,p)%Sunarthsh prooptikhs kameras
sizeP = size(p);%Ypologismos megethous pinaka P
cz = cross(cx,cy);%Ypologismos exwterikou ginomenou x,y wste na vrethei to z
R = [cx cy cz];%Ypologismos pinaka peristrofhs
pccs = systemtrans(R,p,cv);%Klhsh ths systemtrans wste na ekfrastoun ta shmeia ws pros to susthma suntetagmenwn ths kameras
for i = 1:sizeP(2)%Ekkinhsh epanalhpshs gia ton upologismo ths provolhs twn shmeiwn
    if pccs(3,i) > 0
        P(1,i) = w*pccs(1,i)/pccs(3,i);%Provolh twn shmeiwn X 
        P(2,i) = w*pccs(2,i)/pccs(3,i);%Provolh twn shmeiwn Y
    end
end
end

