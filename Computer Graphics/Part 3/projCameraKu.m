function P = projCameraKu(w,cv,cK,cu,p)%Sunarthsh prooptikhs provolhs
CK = cK - cv;%Ypologismos dianusmatos CK
cz = CK/norm(CK);%Ypologismos dianusmatos z
t = cu - dot(cu,cz)*cz;%Ypologismos t
cy = t/norm(t);%Ypologismos dianusmatos y
cx = cross(cy,cz);%Ypologismos dianusmatos x apo to exwteriko ginomeno twn y kai z
P = projCamera(w,cv,cx,cy,p);%Klhsh sunarthshs gia prooptikh provolh
end

