% Napoleon-Christos Oikonomou AEM:7952

function ret = iAACoder2(AACSeq2, fNameOut )
%
% Inverse of AACoder2

x = zeros((length(AACSeq2) + 1) * 1024, 2);
for i = 1 : length(AACSeq2)
    
    if(strcmp(AACSeq2(i).frameType, 'ESH'))
        frameFout = zeros(128,8,2);
        frameFoutTest = iTNS(AACSeq2(i).chl.frameF, AACSeq2(i).frameType, AACSeq2(i).chl.TNScoeffs);
        frameFout(:,:,1) = frameFoutTest;
        frameFoutTest2 = iTNS(AACSeq2(i).chr.frameF, AACSeq2(i).frameType, AACSeq2(i).chr.TNScoeffs);
        frameFout(:,:,2) = frameFoutTest2;
        frameT = iFilterbank([frameFout(:,:, 1), frameFout(:,:, 2)], AACSeq2(i).frameType, AACSeq2(i).winType); 
    else
        frameFout = zeros(1024,2);
        frameFout(:, 1) = iTNS(AACSeq2(i).chl.frameF, AACSeq2(i).frameType, AACSeq2(i).chl.TNScoeffs);
        frameFout(:, 2) = iTNS(AACSeq2(i).chr.frameF, AACSeq2(i).frameType, AACSeq2(i).chr.TNScoeffs);
        frameT = iFilterbank([frameFout(:, 1), frameFout(:, 2)], AACSeq2(i).frameType, AACSeq2(i).winType);
    end
    for j = 1 : 2048
        x((i - 1) * 1024 + j, 1) = x((i - 1) * 1024 + j, 1) + frameT(j, 1);
        x((i - 1) * 1024 + j, 2) = x((i - 1) * 1024 + j, 2) + frameT(j, 2);
    end
end
x(x > 1) = 1;
x(x < -1) = -1;
x = x(1025 : size(x, 1) - 1024, :);
audiowrite(fNameOut, x, 48000);
if (nargout == 1)
    ret = x;
end
end

