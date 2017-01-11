function R = rotmat(th,u)%Dhlwsh sunarthshs rotmat me orismata th h gwnia peristrofhs kai u to parallhlo dianusma ston axona peristrofhs.
  %thetw ws R1,R2,R3 tous 3 orous pou sunthetoun ton pinaka peristrofhs R.
    R1 = (1-cos(th))*(u*(u.'));
    R2 = cos(th)*eye(3);
    ar = [0 u(3) -u(2);-u(3) 0 u(1);u(2) -u(1) 0];
    R3 = sin(th)*ar;
    R = R1 + R2 - R3;%prosthetw tous 3 orous kai epistrefw ton pinaka peristrofhs.
end

