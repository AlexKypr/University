% Napoleon-Christos Oikonomou AEM:7952
% Alexandros-Charalampos Kyprianidis AEM:8012

function [R,F] = hannfft(frame,N,frameType)
%calculate the Hann window,multiply with frame,calcuate fft of that and
%return absolute value and phase of every discrete frequency
R = zeros(1024,1);
F = zeros(1024,1);
switch frameType%check the frameType
    case 'ESH'%in case of ESH
        length = N/8;%256
        window = zeros(length,1);%calculate length of window
        window(1:length) = 0.5 - 0.5*cos(pi*(1:length+0.5)/length);%calculate hann window
       for i = 0:7 %for every subframe
          Etemp((1+i*256):((i+1)*256)) = frame((449+i*128):(448+i*128+256)) .* window;%divide frame in subframes and multiply with window cause of ESH
          EFFTtemp((1+i*128):((i+1)*128)) = fft(Etemp((1+i*256):(128+i*256)));%apply FFT in every subframe
          R((1+i*128):((i+1)*128)) = abs(EFFTtemp((1+i*128):(128*(i+1))));%take the absolute value 
          F((1+i*128):((i+1)*128)) = unwrap(angle(EFFTtemp((1+i*128):(128*(i+1)))));%take the phase
       end  
    otherwise%in case of anything else
        length = N;%2048
        window = zeros(length,1);%calculate length of window
        window(1:length) = 0.5 - 0.5*cos(pi*(1:length+0.5)/length);%calculate hann window
        temp = frame.* window; %Apply the Hann window
        FFTtemp = fft(temp);%apply FFT in the frame
        R(1:1024) = abs(FFTtemp(1:1024));%take the absolute value 
        F(1:1024) = unwrap(angle(FFTtemp(1:1024)));%take the phase
end


end
