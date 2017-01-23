% Napoleon-Christos Oikonomou AEM:7952
% Alexandros-Charalampos Kyprianidis AEM:8012

function P = getEnergy(frameF, frameType)
%
% Calculate the energy of a frame of MDCT coefficients using the type of 
% the frame and the values of the corresponding bands, taken from the 
% file TableB219.mat

load('TableB219.mat');
longFrameBands = B219a(:, 2); %#ok<NODEF>
shortFrameBands = B219b(:, 2); %#ok<NODEF>
shortFrameBands(43) = 128; % for MATLAB 
longFrameBands(70) = 1024; % for MATLAB 

if strcmp(frameType, 'ESH') == 1
    P = zeros(42, 8);
	for i = 0 : 7
        for j = 1 : 42
            for k = (shortFrameBands(j) + 1) : 1 : shortFrameBands(j + 1)
                P(j, i + 1) = P(j, i + 1) + frameF(k + i*128)^2;
            end
        end
	end
else
    P = zeros(69, 1);
	for j = 1 : 69
        for k = (longFrameBands(j) + 1) : 1 : longFrameBands(j + 1)
            P(j) = P(j) + frameF(k)^2;
        end
	end
end
end