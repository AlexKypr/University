% Napoleon-Christos Oikonomou AEM:7952
% Alexandros-Charalampos Kyprianidis AEM:8012

function AACSeq2 =  AACoder2(fNameIn)
%
% Returns the AAC coded signal from signal in fNameIn
[sampleData, ~] = audioread(fNameIn);
%initialize the length of the audio filterbank
N = length(sampleData);
%we reduce the samples so that we have frames of 2048 length
N = N - mod(N, 2048);
%with padarray we fill 1024 zeros to the start and end of the samples
sampleData = padarray(sampleData(1 : N, :), 1024, 'both');
%increase the length by 2048 because of the padarray
N = N + 2048;
%initialize the struct of AACSeq2
AACSeq2 = struct('frameType', {}, 'winType', {}, 'chl', ...
    struct('TNScoeffs', {}, 'frameF', {}), 'chr',struct('TNScoeffs', {}, 'frameF', {}));
%initialize prevType
prevType = 'OLS';
%we process the signal by frames of 2048 length.
%But we want the frames to overlap so we increment by 1024(1-2048,2049-3072...)
for i = 1 : N/1024 - 2
    %call the function SCC for every frame(we process both the channels)
    prevType = SSC(sampleData(i * 1024 + 1 : (i + 2) * 1024, :), prevType);
    %set value to frameType
	AACSeq2(i).frameType = prevType;
    %choose the window type(KBD/SIN)
	AACSeq2(i).winType = 'KBD';
    %call the function filterbank
	frameF = filterbank(sampleData((i - 1) * 1024 + 1 : (i + 1) * 1024 , :), AACSeq2(i).frameType, AACSeq2(i).winType );
    %get quantized sample and TNS coefficients depending the frame type 
    if(strcmp(AACSeq2(i).frameType, 'ESH'))
        [leftFrameF, leftTNScoeffs] = TNS(frameF(:,:, 1), AACSeq2(i).frameType);
    else
        [leftFrameF, leftTNScoeffs] = TNS(frameF(:, 1), AACSeq2(i).frameType);
    end
    if(strcmp(AACSeq2(i).frameType, 'ESH'))
        [rightFrameF, rightTNScoeffs] = TNS(frameF(:,:, 2), AACSeq2(i).frameType);
    else 
        [rightFrameF, rightTNScoeffs] = TNS(frameF(:, 2), AACSeq2(i).frameType);
    end
    %set values to struct
    AACSeq2(i).chl.TNScoeffs = leftTNScoeffs;
    AACSeq2(i).chr.TNScoeffs = rightTNScoeffs;
    AACSeq2(i).chl.frameF = leftFrameF;
    AACSeq2(i).chr.frameF = rightFrameF;
end
end
