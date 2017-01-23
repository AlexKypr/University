% Napoleon-Christos Oikonomou AEM:7952
% Alexandros-Charalampos Kyprianidis AEM:8012

function AACSeq3 =  AACoder3(fNameIn, fnameAACoded)
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
%initialize the struct of AACSeq3
AACSeq3 = struct('frameType', {}, 'winType', {}, 'chl', ...
    struct('TNScoeffs', {}, 'T', {}, 'G', {},...
    'sfc', {}, 'stream', {}, 'codebook', {}), 'chr', ...
    struct('TNScoeffs', {}, 'T', {}, 'G', {},...
    'sfc', {}, 'stream', {}, 'codebook', {}));
%initialize prevType
prevType = 'OLS';

huffLUT = loadLUT();
%we process the signal by frames of 2048 length.
%But we want the frames to overlap so we increment by 1024(1-2048,2049-3072...)
for i = 1 : N/1024 - 2
    %call the function SCC for every frame(we process both the channels)
    prevType = SSC(sampleData(i * 1024 + 1 : (i + 2) * 1024, :), prevType);
    %set value to frameType
	AACSeq3(i).frameType = prevType;
    %choose the window type(KBD/SIN)
	AACSeq3(i).winType = 'KBD';
    %call the function filterbank
	frameF = filterbank(sampleData((i - 1) * 1024 + 1 : (i + 1) * 1024 , :), AACSeq3(i).frameType, AACSeq3(i).winType );
    %get quantized sample and TNS coefficients depending the frame type 
    if(strcmp(AACSeq3(i).frameType, 'ESH'))
        [leftFrameF, leftTNScoeffs] = TNS(frameF(:,:, 1), AACSeq3(i).frameType);
    else 
        [leftFrameF, leftTNScoeffs] = TNS(frameF(:, 1), AACSeq3(i).frameType);
    end
    % calculates SMR for left channel
    if i == 1
        leftSMR = psycho(sampleData((i - 1) * 1024 + 1 : (i + 1) * 1024 , 1),AACSeq3(i).frameType,zeros(2048,1),zeros(2048,1));
    elseif i == 2
        leftSMR = psycho(sampleData((i - 1) * 1024 + 1 : (i + 1) * 1024 , 1),AACSeq3(i).frameType,sampleData((i - 2) * 1024 + 1 : i * 1024 , 1),zeros(2048,1));
    else
        leftSMR = psycho(sampleData((i - 1) * 1024 + 1 : (i + 1) * 1024 , 1),AACSeq3(i).frameType,sampleData((i - 2) * 1024 + 1 : i * 1024 , 1),sampleData((i - 3) * 1024 + 1 : (i - 1)* 1024 , 1));
    end
    leftP = getEnergy(leftFrameF, AACSeq3(i).frameType);
    leftT = leftP ./ leftSMR;
    %calculates quantized coefficients
    [leftS, leftsfc, leftG] = AACquantizer(leftFrameF, AACSeq3(i).frameType, leftSMR);
    % huffman encoding on S coefficients
    [leftstream, leftcodebook] = encodeHuff(leftS, huffLUT);
    leftsfc = round(leftsfc);
    
    if(strcmp(AACSeq3(i).frameType, 'ESH'))
       leftsfccell = cell(8,1);
        for k = 0:7
         [leftsfctemp, ~] = encodeHuff(leftsfc(2:42,k+1), huffLUT, 12);
         leftsfccell{k+1} = leftsfctemp;
        end
    else
        [leftsfccell, ~] = encodeHuff(leftsfc(2:69), huffLUT, 12);
    end
    % set data to struct
    AACSeq3(i).chl.TNScoeffs = leftTNScoeffs;
    AACSeq3(i).chl.T = leftT;
    AACSeq3(i).chl.G = leftG;
    AACSeq3(i).chl.sfc = leftsfccell;
    AACSeq3(i).chl.stream = leftstream;
    AACSeq3(i).chl.codebook = leftcodebook;
    
    if(strcmp(AACSeq3(i).frameType, 'ESH'))
        [rightFrameF, rightTNScoeffs] = TNS(frameF(:,:, 2), AACSeq3(i).frameType);
    else 
        [rightFrameF, rightTNScoeffs] = TNS(frameF(:, 2), AACSeq3(i).frameType);
    end
    if i == 1
        rightSMR = psycho(sampleData((i - 1) * 1024 + 1 : (i + 1) * 1024 , 2),AACSeq3(i).frameType,zeros(2048,1),zeros(2048,1));
    elseif i == 2
        rightSMR = psycho(sampleData((i - 1) * 1024 + 1 : (i + 1) * 1024 , 2),AACSeq3(i).frameType,sampleData((i - 2) * 1024 + 1 : i * 1024 , 2),zeros(2048,1));
    else
        rightSMR = psycho(sampleData((i - 1) * 1024 + 1 : (i + 1) * 1024 , 2),AACSeq3(i).frameType,sampleData((i - 2) * 1024 + 1 : i * 1024 , 2),sampleData((i - 3) * 1024 + 1 : (i - 1)* 1024 , 2));
    end
    rightP = getEnergy(rightFrameF, AACSeq3(i).frameType);
    rightT = rightP ./ rightSMR;
    [rightS, rightsfc, rightG] = AACquantizer(rightFrameF, AACSeq3(i).frameType, rightSMR);
    [rightstream, rightcodebook] = encodeHuff(rightS, huffLUT);
    rightsfc = round(rightsfc);
    if(strcmp(AACSeq3(i).frameType, 'ESH'))
       rightsfccell = cell(8,1);
        for k = 0:7
         [rightsfctemp, ~] = encodeHuff(rightsfc(2:42,k+1), huffLUT, 12);
         rightsfccell{k+1} = rightsfctemp;
        end
    else
        [rightsfccell, ~] = encodeHuff(rightsfc(2:69), huffLUT, 12);
    end
    AACSeq3(i).chr.TNScoeffs = rightTNScoeffs;
    AACSeq3(i).chr.T = rightT;
    AACSeq3(i).chr.G = rightG;
    AACSeq3(i).chr.sfc = rightsfccell;
    AACSeq3(i).chr.stream = rightstream;
    AACSeq3(i).chr.codebook = rightcodebook;
end
save (fnameAACoded, 'AACSeq3');
end
