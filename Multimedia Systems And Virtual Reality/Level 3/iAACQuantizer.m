% Napoleon-Christos Oikonomou AEM:7952
% Alexandros-Charalampos Kyprianidis AEM:8012

function frameF = iAACQuantizer(S, sfc, G, frameType)
%the inverse function of AACQuantizer
%

load('TableB219.mat');%loads the table
longFrameBands = B219a(:, 2); %#ok<NODEF>
longFrameBands(70) = 1023;
shortFrameBands = B219b(:, 2); %#ok<NODEF>
shortFrameBands(43) = 127;

if(strcmp(frameType,'OLS') || strcmp(frameType,'LSS') || strcmp(frameType,'LPS'))
    %check frameType
    a = zeros(69,1);
    frameF = zeros(1024, 1);
    a(1) = G(1);%set a = globan gain
    for i = 2 : 69%for the rest values of a
        a(i) = a(i - 1) + sfc(i);%set a
    end
    for i = 1 : 69
        for j = longFrameBands(i) + 1 : longFrameBands(i + 1)
            frameF(j) = sign(S(j)) * abs(S(j))^(4/3) * 2^(a(i)/4);%use inverse quantization to calculate the samples of frame in frequency domain
        end
    end
    
elseif(strcmp(frameType,'ESH'))
    %check frameType
    frameF = zeros(128,8);
    a = zeros(42,8);
    a(1,:) = G(1,:);% set a = global gain
    for k = 0 : 7%for every subframe
        for i = 2 : 42%for the rest values of a
            a(i, k + 1) = a(i - 1, k + 1) + sfc(i, k + 1);% set a
        end
        for i = 1 : 42
            for j = shortFrameBands(i) + 1 : shortFrameBands(i + 1)
                frameF(j,k+1) = sign(S(k * 128 + j)) * ...
                    abs(S(k * 128 + j))^(4/3) * 2^(a(i,k+1)/4);%use inverse quantization to calculate the samples of frame in frequency domain
            end
        end
    end
end
end

