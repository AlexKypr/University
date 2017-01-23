% Napoleon-Christos Oikonomou AEM:7952
% Alexandros-Charalampos Kyprianidis AEM:8012

function ret = iAACoder1(AACSeq1, fNameOut )
%
% Inverse of AACoder1
%initialize the array that we will save the decoded signal
x = zeros((length(AACSeq1) + 1) * 1024, 2);
for i = 1 : length(AACSeq1)
    %call iFilterbank
    frameT = iFilterbank([AACSeq1(i).chl.frameF, AACSeq1(i).chr.frameF], AACSeq1(i).frameType, AACSeq1(i).winType);
    %we add to every last 1024 samples of the previous frame the first 1024 samples of the current frame
    %This is the process of overlapping
    for j = 1 : 2048
        x((i - 1) * 1024 + j, 1) = x((i - 1) * 1024 + j, 1) + frameT(j, 1);
        x((i - 1) * 1024 + j, 2) = x((i - 1) * 1024 + j, 2) + frameT(j, 2);
    end
end
x(x > 1) = 1;
x(x < -1) = -1;
x = x(1025 : size(x, 1) - 1024, :);
%set to audio file with name = fNameOut the array x
audiowrite(fNameOut, x, 48000);
if (nargout == 1)
    ret = x;
end
end

