% Napoleon-Christos Oikonomou AEM:7952
% Alexandros-Charalampos Kyprianidis AEM:8012

function [ S, sfc, G] = AACquantizer(frameF, frameType, SMR)
%It calculates Globan Gain,scalefactors and the symbols of quantization of
%MDCT coefficients
%

load('TableB219.mat');%load the table
longFrameBands = B219a(:, 2); %#ok<NODEF>
longFrameBands(70) = 1024;
shortFrameBands = B219b(:, 2); %#ok<NODEF>
shortFrameBands(43) = 128;
P = getEnergy(frameF, frameType);%calculate the energy of MDCT coefficients
T = P ./ SMR;%calculate loudness threshold
MagicNumber = 0.4054;

if(strcmp(frameType, 'OLS') || strcmp(frameType, 'LSS') || strcmp(frameType, 'LPS'))
   %check type of frame
    S = zeros(1024, 1);
    X_hat = zeros(1024, 1);
    a = zeros(69, 1);
    for i = 1 : 69%for every band
        a(i) = (16/3) * log2((max(frameF) ^ 0.75) / 8191);%calculate first estimation of scalefactor gain
    end
    for i = 1 : 69%for every band
        for j = longFrameBands(i) + 1 : longFrameBands(i + 1)%for every frequency between the limits(longFrameBands(i) + 1-longFrameBands(i + 1))
            S(j) = sign(frameF(j)) * fix(((abs(frameF(j)) * (2^-(a(i)/4)))^(3/4) + MagicNumber));%calculate symbols of MDCT coefficients
            X_hat(j) = sign(S(j)) * abs(S(j))^(4/3) * 2^(a(i)/4);%inverse quantization
        end
    end
    check = zeros(69,1);%create vector to check for every entry if the condtion for exit has been met.Only if all the entries have met the conditions it exits.
    flag = zeros(69,1);
  
    while(~all(check))%check if the conditions are true
     for i = 1 : 69
        if(check(i) == 1 && flag(i) == 1)%check if i-th entry has been checked and it has exited because of differences of consecutive entries
            if(i == 69)%if i = 69
                if(abs(a(69) - a(68)) >= 59)%if the difference is still >= 59 
                    continue;%skip this iteration
                else%if the difference is smaller
                    check(i) = 0;%set check to 0
                    flag(i) = 0;%set flag to 0
                end
            elseif(i == 1)%if i = 1
                 if(abs(a(1)-a(2)) >= 59)%if the difference is still >= 59
                     continue;%skip iteration
                 else%if it has changed
                     check(i) = 0;%set check to 0
                     flag(i) = 0;%set flag to 0
                 end
            else
             if(any(abs(diff(a(i-1:i+1))) >= 59))%if the difference is still >=59
                 continue;%skip iteration
             else%if it has changed
                 check(i) = 0;%set check to 0
                 flag(i) = 0;%set flag to 0
             end
            end
        elseif(check(i) == 1 && flag(i) == 0)%check if i-th entry has been checked and it has exited because of the power of quantization error
            continue;
        end
        if(i == 69)%if i = 69 then
            if(abs(a(69) - a(68)) >= 59)%we want to check only the previous not the following
                check(i) = 1;%if the condition is true then we set check to 1 so it doesn't increase
                flag(i) = 1;%we set flag(i) = 1 because the exit condition is the difference between consecutive entries 
                continue;
            end
        elseif(i == 1)%if i = 1 then
            if(abs(a(1) - a(2)) >= 59)%we want to check only the following not the previous
                check(i) = 1;%set check = 1 if its tru
                flag(i) = 1;%set flag = 1 if its true
                continue;%skip iteration
            end
        else
            if(any(abs(diff(a(i-1:i+1))) >= 59))%we check the previous and the following entry
               check(i) = 1;%set check = 1
               flag(i) = 1;%set flag = 1
               continue;%skip iteration
            end
        end
       
        e(longFrameBands(i) + 1 : longFrameBands(i + 1)) = ...
                frameF(longFrameBands(i) + 1 : longFrameBands(i + 1)) - ...
                X_hat(longFrameBands(i) + 1 : longFrameBands(i + 1));
            %calculate the quantization error
            P_e=0;
            for j = longFrameBands(i) + 1 : longFrameBands(i + 1)%for the range of the frequencies
                P_e = P_e + e(j)^2;%calculate the power of quantization error
            end

        check_2 = sign(P_e - T(i));%set to check_2 = (0,1,-1) if its P_e>T(i) => 1 else if P_e = T(i) => 0 else -1
            if(check_2 >= 0)% if its bigger or equal to 0 
                check(i) = 1;%set check = 1
                continue;%skip iteration
            end
            a(i) = a(i) + 1;%increase a by 1 because it has not exited
          
         for j = longFrameBands(i) + 1 : longFrameBands(i + 1)
            S(j) = sign(frameF(j)) * fix(((abs(frameF(j)) / (2^(a(i)/4)))^(3/4) + MagicNumber));%calculate the new  symbols of MDCT coefficients
            X_hat(j) = sign(S(j)) * abs(S(j))^(4/3) * 2^(a(i)/4);%calculate the new x_hat
         end
     end
    end
    G = a(1);%set global gain = a(i)
    sfc = zeros(69, 1);%set all sfc to zero
    sfc(1) = G;%set sfc(1) = global gain
    for i = 2 : 69
        sfc(i) = a(i) - a(i - 1);%set sfc
    end
    
elseif(strcmp(frameType, 'ESH'))
    %check type of frame
    S = zeros(1024, 1);
    X_hat = zeros(1024, 1);
    a = zeros(42,8);
    for k = 0 : 7 %for every subframe  
        for i = 1 : 42%for every band
            a(:,k+1) = (16/3) * log2(max(frameF(:,k+1)) ^ 0.75 / 8191);%calculate first estimation of scalefactor gain
        end    
        for i = 1 : 42%for every band
            for j = shortFrameBands(i) + 1 : shortFrameBands(i + 1)%for every frequency between the limits(shortFrameBands(i) + 1-shortFrameBands(i + 1))
                S((k * 128 + j)) = sign(frameF(j,k+1)) * ...
                    fix(((abs(frameF(j,k+1)) / (2^(a(i,k+1)/4)))^(3/4) + MagicNumber));%calculate symbols of MDCT coefficients
                X_hat((k * 128 + j)) = sign(S((k * 128 + j))) * ...
                    abs(S((k * 128 + j)))^(4/3) * 2^(a(i,k+1)/4);%inverse quantization
            end
        end
    end
    
    check = zeros(42,8);%create vector to check for every entry if the condtion for exit has been met.Only if all the entries have met the conditions it exits.
    flag = zeros(42,8);
    for k = 0:7
    while(~all(check(:,k+1)))%check if the conditions are true
     for i = 1 : 42%for every band
        if(check(i,k+1) == 1 && flag(i,k+1) == 1)%check if i-th entry has been checked and it has exited because of differences of consecutive entries
            if(i == 42)%if i = 42
                if(abs(a(42,k+1)-a(41,k+1)) >= 59)%if the difference is still >= 59 
                    continue;%skip iteration
                else%if it has changed
                    flag(i,k+1) = 0;%set flag = 0
                    check(i,k+1) = 0;%set check = 0
                end
            elseif(i == 1)%if i = 1
                 if(abs(a(1,k+1)-a(2,k+1)) >= 59)%if the difference is still >= 59 
                     continue;%skip iteration
                 else%if it has changed
                     flag(i,k+1) = 0;%set flag = 0
                    check(i,k+1) = 0;%set check = 0
                 end
            else
                if(any(abs(diff(a(i-1:i+1,k+1))) >= 59))%if the difference is still >= 59 
                    continue;%skip iteration
                else%if it has changed
                     flag(i,k+1) = 0;%set flag = 0
                    check(i,k+1) = 0;%set check = 0
                end
            end
        elseif(check(i,k+1) == 1 && flag(i,k+1) == 0)%check if i-th entry has been checked and it has exited because of the power of quantization error
            continue;%skip iteration
        end
        if(i == 42)
            if(abs(a(42,k+1)-a(41,k+1)) >= 59)%we want to check only the previous not the following
                check(i,k+1) = 1;%set check = 1
                flag(i,k+1) = 1;%set flag = 1
                continue;%skip iteration
            end
        elseif(i == 1)%we want to check only the following not the previous
            if(abs(a(1,k+1)-a(2,k+1)) >= 59)
                check(i,k+1) = 1;%set check = 1
                flag(i,k+1) = 1;%set flag = 1
                continue;%skip iteration
            end
        else
            if(any(abs(diff(a(i-1:i+1,k+1))) >= 59))%we check the previous and the following entry
               check(i,k+1) = 1;%set check = 1
               flag(i,k+1) = 1;%set flag = 1
               continue;%skip iteration
            end
        end
        e(shortFrameBands(i) + 1 : shortFrameBands(i + 1),1) = ...
                     frameF((shortFrameBands(i) + 1):(shortFrameBands(i + 1)),k+1) - ...    
                 X_hat((k * 128 + shortFrameBands(i) + 1)...
                      : (k * 128 + shortFrameBands(i + 1)));
                  %calculate the quantization error
        P_e = 0;
        for j = shortFrameBands(i) + 1 : shortFrameBands(i + 1)%for the range of the frequencies
                P_e = P_e + e(j,1)^2;%calculate the power of quantization error
        end
        check_2 = sign(P_e - T(i,k+1));%set to check_2 = (0,1,-1) if its P_e>T(i) => 1 else if P_e = T(i) => 0 else -1
            if(check_2 >= 0)% if its bigger or equal to 0 
                check(i,k+1) = 1;%set check = 1
                continue;%skip iteration
            end
        
         a(i,k+1) = a(i,k+1) + 1;%increase a by 1 because it has not exited
         for j = shortFrameBands(i) + 1 : shortFrameBands(i + 1)
                S((k * 128 + j)) = sign(frameF(j,k+1)) * ...
                    fix(((abs(frameF(j,k+1)) / (2^(a(i,k+1)/4)))^(3/4) + MagicNumber));%calculate the new  symbols of MDCT coefficients
                X_hat((k * 128 + j)) = sign(S((k * 128 + j))) * ...
                    abs(S((k * 128 + j)))^(4/3) * 2^(a(i,k+1)/4);%calculate the new x_hat
          end
     end
    end
    end
    G = zeros(1, 8);
    sfc = zeros(42, 8);
    for k = 0 : 7%for every subframe
        G(1,k + 1) = a(1,k+1);%set global gain = a(i)
        sfc(1, k + 1) = G(1,k + 1);%set sfc(1) = global gain
        for i = 2 : 42
            sfc(i, k + 1) = a(i,k+1) - a(i-1,k+1);%set sfc
        end
    end
end
end
