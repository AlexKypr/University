% Napoleon-Christos Oikonomou AEM:7952
% Alexandros-Charalampos Kyprianidis AEM:8012

function ret = iAACoder3(AACSeq3, fNameOut)
%
% Inverse of AACoder3

x = zeros((length(AACSeq3) + 1) * 1024, 2);
huffLUT = loadLUT();
for i = 1 : length(AACSeq3)
        S(:, 1) = decodeHuff(AACSeq3(i).chl.stream, AACSeq3(i).chl.codebook, huffLUT);
        S(:, 2) = decodeHuff(AACSeq3(i).chr.stream, AACSeq3(i).chr.codebook, huffLUT);
    if(strcmp(AACSeq3(i).frameType, 'ESH'))
         frameFout = zeros(128,8,2);
    end
    if(strcmp(AACSeq3(i).frameType, 'ESH'))
       
        leftsfc = zeros(42,8);
        leftsfc(1,:) = AACSeq3(i).chl.G(1,:);
        for k = 0:7
         leftsfc(2:42,k+1) = decodeHuff(AACSeq3(i).chl.sfc{k+1}, 12, huffLUT);
        end
         frameF1 = iAACQuantizer(S(:, 1), leftsfc, AACSeq3(i).chl.G , AACSeq3(i).frameType);
         frameFoutTest = iTNS(frameF1, AACSeq3(i).frameType, AACSeq3(i).chl.TNScoeffs);
         frameFout(:,:,1) = frameFoutTest;
     else
        leftsfc = zeros(69,1);
        leftsfc(1,1) = AACSeq3(i).chl.G;
        leftsfc(2:69,1) = decodeHuff(AACSeq3(i).chl.sfc, 12, huffLUT);
        frameF1 = iAACQuantizer(S(:, 1), leftsfc, AACSeq3(i).chl.G , AACSeq3(i).frameType);
        frameFout = iTNS(frameF1, AACSeq3(i).frameType, AACSeq3(i).chl.TNScoeffs);
    
    end
     if(strcmp(AACSeq3(i).frameType, 'ESH'))
        rightsfc = zeros(42,8);
        rightsfc(1,:) = AACSeq3(i).chr.G(1,:);
        for k = 0:7
         rightsfc(2:42,k+1) = decodeHuff(AACSeq3(i).chr.sfc{k+1}, 12, huffLUT);
        end
        frameF2 = iAACQuantizer(S(:, 2), rightsfc, AACSeq3(i).chr.G , AACSeq3(i).frameType);
        frameFoutTest = iTNS(frameF2, AACSeq3(i).frameType, AACSeq3(i).chr.TNScoeffs);
        frameFout(:,:,2) = frameFoutTest;
        frameT = iFilterbank([frameFout(:,:, 1), frameFout(:,:, 2)], AACSeq3(i).frameType, AACSeq3(i).winType);
    
     else
        rightsfc = zeros(69,1);
        rightsfc(1,1) = AACSeq3(i).chr.G;
        rightsfc(2:69,1) = decodeHuff(AACSeq3(i).chr.sfc, 12, huffLUT);
        frameF2 = iAACQuantizer(S(:, 2), rightsfc, AACSeq3(i).chr.G , AACSeq3(i).frameType);
        frameFout(:, 2) = iTNS(frameF2, AACSeq3(i).frameType, AACSeq3(i).chr.TNScoeffs);
        frameT = iFilterbank([frameFout(:, 1), frameFout(:, 2)], AACSeq3(i).frameType, AACSeq3(i).winType);
    
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

