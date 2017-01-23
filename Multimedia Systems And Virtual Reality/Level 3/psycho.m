% Napoleon-Christos Oikonomou AEM:7952
% Alexandros-Charalampos Kyprianidis AEM:8012

function SMR = psycho(frameT, frameType, frameTprev1, frameTprev2)
% Calculate SMR in order to calculate T so we don't encode every frequency 
%%step 0   
N = size(frameT,1);%calculate the size of the frame
load('TableB219.mat');%load the table
load('Ssf_Lsf.mat');%load the values that spreading function calculates
%We make Ssf_Lsf.mat by running the code for one time and then we saved in
%order to save computing power.
switch frameType %check the frameType
    case 'ESH' %in case of ESH
        wlow = B219b(:, 2); %#ok<*NODEF>
        whigh = B219b(:, 3); %wlow and whigh are the limits of the index of the samples that compose a band
        qsthr = B219b(:,6);

        %%step 2
        [R,F] = hannfft(frameT,N,frameType);%call the hannfft function that calculates the fft of the frame after the multiplication of subframe with Hann window.
        [Rprev,Fprev] = hannfft(frameTprev1,N,frameType);%same as before but for the previous frame
        %%step 3
        Rpred(1:128,1) = 2*Rprev((1024-127):1024) - Rprev((1024-255):(1024-128));%predict absolute value of the first subframe 
        Fpred(1:128,1) = 2*Fprev((1024-127):1024) - Fprev((1024-255):(1024-128));%predict angle of the first subframe 
        Rpred(129:256,1) = 2*R(1:128) - Rprev((1024-127):1024); %predict absolute value of the second subframe 
        Fpred(129:256,1) = 2*F(1:128) - Fprev((1024-127):1024);%predict angle of the second subframe 
        for i = 2:7
             Rpred((128*i+1):((i+1)*128),1) = 2*R((128*(i-2)+1):(128*(i-1))) - R((128*(i-1)+1):(128*i));%predict absolute value of the 3-8 subframe 
             Fpred((128*i+1):((i+1)*128),1) = 2*F((128*(i-2)+1):(128*(i-1))) - F((128*(i-1)+1):(128*i));%predict angle of the 3-8 subframe 
        end
         %%step 4
         cw = sqrt((R.*cos(F) - Rpred.*cos(Fpred)).^2 + (R.*sin(F) - Rpred.*sin(Fpred)).^2)./(R + abs(Rpred));%calculate predictability
         %%step 5
         energy = zeros(42,8);
         cb = zeros(42,8);
         for i = 0:7%for every subframe
            for j = 1:42%for all bands
                for k = (wlow(j)+1):(whigh(j)+1)%for all the samples between wlow(j) +1 - whigh(j) + 1
                    energy(j,i+1) = energy(j,i+1) + R(k + i*128)^2;%calculate energy
                    cb(j,i+1) = cb(j,i+1) + cw(k + i*128).*R(k + i*128)^2;%calculate weighted predictability
                end
            end
         end
         %%step 6
         ecb = zeros(42,8);
         ct = zeros(42,8);
         for i = 1:8%for every subframe 
            for b = 1:42 %for the b-th band
                for bb = 1:42%for the bb-th band
                     ecb(b,i) = ecb(b,i) + energy(bb,i).*Ssf(bb,b); %combine energy with Ssf
                     ct(b,i) = ct(b,i) + cb(bb,i).*Ssf(bb,b);%combine predictability with Ssf
                end
            end
         end
        cb = ct./ecb;%normalize predictability
        en = zeros(42, 8);
        for i = 1:8
            en(1:42,i) = ecb(1:42,i)./(sum(Ssf(:,1:42))');%normalize energy
        end
        %%step 7
        tb = -0.299 - 0.43*log(cb);%calculate tonality index (0,1)
        %%step 8
        NMT(1:42,1) = 6;%set Noise Masking Tone(6db)
        TMN(1:42,1) = 18;%set Tone Masking Noise(18db)
        SNR = zeros(42,8);
        for i = 1:8
            SNR(1:42,i) = tb(1:42,i).*TMN + (1-tb(1:42,i)).*NMT;%Calculate SNR for every band and for every subframe
        end
        %%step 9
        bc = 10.^(-SNR/10);%convert db to energy ratio
        %%step 10
        nb = en.*bc;%calculate energy threshold
        %%step 11
        qthr = zeros(42,8);
        npart = zeros(42,8);
        for i = 1:8
            qthr(:,i) = eps()*128*10.^(qsthr(:,1)/10);%threshold of silence
            npart(:,i) = max(nb(:,i),qthr(:,i));%calculate level of noise by taking max of nb and qthr
        end
        %%step 12
        SMR = energy./npart;%calculate Signal to Noise Mask Ratio
    otherwise
        wlow = B219a(:, 2);
        whigh = B219a(:, 3);
        qsthr = B219a(:,6);

        %%step 2
        [R,F] = hannfft(frameT,N,frameType);%call the hannfft function that calculates the fft of the frame after the multiplication of frame with Hann window.
        [Rprev,Fprev] = hannfft(frameTprev1,N,frameType);%same as before but for the previous frame
        [Rprev2,Fprev2] = hannfft(frameTprev2,N,frameType);%same as before but for the pre-previous frame
        %%step 3
        Rpred = 2*Rprev - Rprev2;%predict absolute value
        Fpred = 2*Fprev - Fprev2;%predict phase
        %%step 4
        cw = sqrt((R.*cos(F) - Rpred.*cos(Fpred)).^2 + (R.*sin(F) - Rpred.*sin(Fpred)).^2)./(R + abs(Rpred));%calculate predictability
        %%step 5
        energy = zeros(69,1);
        cb = zeros(69,1);
        for i = 1:69%for all bands
            for j = (wlow(i)+1):(whigh(i)+1)%for all the samples between wlow(j) +1 - whigh(j) + 1
                energy(i) = energy(i) + R(j)^2;%calculate energy
                 cb(i) = cb(i) + cw(j).*R(j)^2;%calculate weighted predictability
            end
        end
        %%step 6
        ecb = zeros(69,1);
        ct = zeros(69,1);
        for b = 1:69%for the b-th band
            for bb = 1:69%for the bb-th band
                 ecb(b) = ecb(b) + energy(bb).*Lsf(bb,b);%combine energy with Lsf
                 ct(b) = ct(b) + cb(bb).*Lsf(bb,b);%combine predictability with Lsf
            end
        end
        cb = ct./ecb;%normalize predictability
        en = ecb./(sum(Lsf(:,1:69))');%normalize energy
        
        %%step 7
        tb = -0.299 - 0.43*log(cb);%calculate tonality index (0,1)
        %%step 8
        NMT(1:69,1) = 6;%set Noise Masking Tone(6db)
        TMN(1:69,1) = 18;%set Tone Masking Noise(18db)
        SNR = tb.*TMN + (1-tb).*NMT;%Calculate SNR for every band
        %%step 9
        bc = 10.^(-SNR/10);%convert db to energy ratio
        %%step 10
        nb = en.*bc;%calculate energy threshold
        %%step 11
        qthr(1:69,1) = eps()*N/2*10.^(qsthr(1:69)/10);%threshold of silence
        npart(1:69,1) = max(nb(1:69),qthr(1:69));%calculate level of noise by taking max of nb and qthr
        %%step 12
        SMR = energy./npart;%calculate Signal to Noise Mask Ratio
end
end
