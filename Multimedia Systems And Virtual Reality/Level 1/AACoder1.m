% Napoleon-Christos Oikonomou AEM:7952
% Alexandros-Charalampos Kyprianidis AEM:8012

function AACSeq1 =  AACoder1(fNameIn)
%
% Returns the AAC coded signal from signal in fNameIn
[sampleData, ~] = audioread(fNameIn);
%initialize the length of the audio filterbank
N = length(sampleData);
%we save how many samples we need so we have frames of 2048 length
rest = mod(N,2048);
%with padarray we fill at start of the samples with 1024 zeros
sampleData = padarray(sampleData(1 : N, :), 1024, 'pre');
%increase the length by 1024 because of the padarray
N = N + 1024;
%with padarray we fill at end of the samples with 1024-rest zeros
sampleData = padarray(sampleData(1 : N, :), 1024-rest, 'post');
%changing the length of sampleData by 1024 - rest because of the padarray
N = N + 1024 - rest;
%initialize the struct of AACSeq1
AACSeq1 = struct('frameType', {}, 'winType', {}, 'chl', struct('frameF', {}),...
   'chr', struct('frameF', {}));
%initialize prevType
prevType = 'OLS';
%we process the signal by frames of 2048 length.
%But we want the frames to overlap so we increment by 1024(1-2048,2049-3072...)
for i = 1 :  N / 1024 - 2
    %call the function SCC for every frame(we process both the channels)
	prevType = SSC(sampleData(i * 1024 + 1 : (i + 2) * 1024, :), prevType);
    %set value to frameType
	AACSeq1(i).frameType = prevType;
    %choose the window type(KBD/SIN)
	AACSeq1(i).winType = 'KBD';
    %call the function filterbank
	frameF = filterbank(sampleData((i - 1) * 1024 + 1 : (i + 1) * 1024 , :), AACSeq1(i).frameType, AACSeq1(i).winType );
    %set value to chlframeF and chrframeF
    if(strcmp(AACSeq1(i).frameType, 'ESH'))
        AACSeq1(i).chl.frameF = frameF(:, :, 1);
        AACSeq1(i).chr.frameF = frameF(:, :, 2);
    else
        AACSeq1(i).chl.frameF = frameF(:, 1);
	    AACSeq1(i).chr.frameF = frameF(:, 2);
    end
	
end
end
