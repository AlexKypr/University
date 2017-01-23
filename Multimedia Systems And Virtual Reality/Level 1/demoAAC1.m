% Napoleon-Christos Oikonomou AEM:7952
% Alexandros-Charalampos Kyprianidis AEM:8012

function SNR = demoAAC1(fNameIn, fNameOut)
%we calculate the SNR of the output signal
%we read the audio file with name = fNameIn
y = audioread(fNameIn);
%call the function AACoder1 so we code our signal
fprintf('Coding: ');
tic;
AACSeq = AACoder1(fNameIn);
toc;
%call the function iAACoder1 so we decode our coded signal
fprintf('Decoding: ');
tic;
x = iAACoder1(AACSeq, fNameOut);
toc;
%we match the length of the original audio file with the processed signal
y = y(1 : length(x), :);
%we calculate the differences of these two signal and we treat it as noise
noise = y - x;
%noise(noise == 0) = eps;
%we calculate the snr

SNR = [snr(y(:,1), noise(:,1)),snr(y(:,2), noise(:,2));];

fprintf('\nLEVEL 1\n======== \n');
fprintf('Channel 1 SNR: %f\n',SNR(1));
fprintf('Channel 2 SNR: %f\n',SNR(2));

end

