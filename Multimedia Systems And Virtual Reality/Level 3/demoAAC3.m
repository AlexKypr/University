% Napoleon-Christos Oikonomou AEM:7952
% Alexandros-Charalampos Kyprianidis AEM:8012

function [SNR, bitrate, compression] = demoAAC3(fNameIn, fNameOut, fNameAACoded)
%we calculate the SNR of the output signal
%we read the audio file with name = fNameIn
y = audioread(fNameIn, 'native'); %#ok<NASGU>
input = whos('y');
y = audioread(fNameIn);
%call the function AACoder3 so we code our signal
fprintf('Coding: ');
tic;
AACSeq3 =  AACoder3(fNameIn, fNameAACoded);
toc;
%call the function iAACoder3 so we decode our coded signal
fprintf('Decoding: ');
tic;
x = iAACoder3(AACSeq3, fNameOut);
toc;
%we match the length of the original audio file with the processed signal
y = y(1 : length(x), :);
%we calculate the differences of these two signal and we treat it as noise
noise = y - x;
%noise(noise == 0) = eps;
%we calculate the snr

SNR = [snr(y(:, 1), noise(:, 1)), snr(y(:, 2), noise(:, 2))];


load (fNameAACoded, 'AACSeq3');
% we calculate the compression
outputsize = 0;
for i = 1 : length(AACSeq3)
    tmp = 2 * numel(AACSeq3(i).frameType) + 2 * numel(AACSeq3(i).winType)...
       +  4 * numel(AACSeq3(i).chl.TNScoeffs) + 128 * numel(AACSeq3(i).chl.G) + 32 * numel(AACSeq3(i).chl.codebook) + numel(AACSeq3(i).chl.sfc) + numel(AACSeq3(i).chl.stream) + ...
          4 * numel(AACSeq3(i).chr.TNScoeffs) + 128 * numel(AACSeq3(i).chr.G) + 32 * numel(AACSeq3(i).chr.codebook) + numel(AACSeq3(i).chr.sfc) + numel(AACSeq3(i).chr.stream);
    outputsize = outputsize + tmp;
end
outputsize = outputsize / 8;

compression = outputsize / input.bytes * 100;
fprintf('Compression ratio : %f %% \n', compression);
% we calculate the bitrate 
time = input.size(1) / 48000;
bitrate(1) = input.bytes / time;
bitrate(2) = outputsize / time;
fprintf('\nLEVEL 3\n======== \n');
fprintf('Channel 1 SNR: %f\n',SNR(1));
fprintf('Channel 2 SNR: %f\n',SNR(2));

end

