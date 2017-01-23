% Napoleon-Christos Oikonomou AEM:7952
% Alexandros-Charalampos Kyprianidis AEM:8012

function frameType = SSC(nextFrameT, prevFrameType)
%
%   Returns the type of frameT.


%Defining the high-pass filter
b = [0.7548 -0.7548];
a = [1 -0.5095];

% Retrieving size and number of channels for next frame
[sizeOfFrame, numberOfChannels] = size(nextFrameT);

%% Step 1
%Filtering next frame
filteredNextFrameT = nextFrameT;
for i = 1 : numberOfChannels
    filteredNextFrameT(:, i) = filter(b, a, nextFrameT(:, i));
end

%% Step 2
%Defining the number of the intervals and their size.
intervalNumber = 8;
intervalSize = sizeOfFrame / intervalNumber;
intervalStart = (sizeOfFrame - (intervalNumber + 1) * (intervalSize / 2)) / 2;

%Calculating the (sigma_l)^2 for the nextFrameT
sigmaLSquared = zeros(intervalNumber, numberOfChannels);
for i = 1 : numberOfChannels
    for j = 1 : intervalNumber
        for k = (intervalStart + j * intervalSize / 2) : (intervalStart + (j + 1) * intervalSize / 2)
            sigmaLSquared(j, i) = sigmaLSquared(j, i) + (filteredNextFrameT(k, i) * filteredNextFrameT(k, i));
        end
    end
end

%% Step 3
%Calculating the attack values
attackValues = zeros(intervalNumber, numberOfChannels);
for i = 1 : numberOfChannels
    %There is no attack value for the (sigma_l)^2 (1), so it is 0.
    attackValues(1, i) = 0;
    for j = 2 : intervalNumber
        sumOfSigmaLSquared = sum(sigmaLSquared(1 : (j - 1), i)) / j;
        attackValues(j, i) = sigmaLSquared(j, i) / sumOfSigmaLSquared;
    end
end

%% Step 4
%decide if the next frame is ESH

for i = 1 : numberOfChannels
    nextFrameType(i, :) = 'OLS'; %#ok<*AGROW>
    for j = 1 : intervalNumber
        if (attackValues(j, i) > 10 && sigmaLSquared(j, i) > 1e-03)
            nextFrameType(i, :) = 'ESH';
        end
    end
end

%% Choosing Process

for i = 1 : numberOfChannels
    if strcmp(prevFrameType, 'OLS') == 1
        if strcmp(nextFrameType(i, :), 'ESH') == 1
            channelsFrameType(i, :) = 'LSS';
        else
            channelsFrameType(i, :) = 'OLS';
        end
    end
    if strcmp(prevFrameType, 'ESH') == 1
        if strcmp(nextFrameType(i, :), 'ESH') == 1
            channelsFrameType(i, :) = 'ESH';
        else
            channelsFrameType(i, :) = 'LPS';
        end
    end
    if strcmp(prevFrameType, 'LSS') == 1
        channelsFrameType(i, :) = 'ESH';
    end
    if strcmp(prevFrameType, 'LPS') == 1
        channelsFrameType(i, :) = 'OLS';
    end
end

%Resulting Common Type
if (strcmp(channelsFrameType(1, :), 'ESH') == 1) || (strcmp(channelsFrameType(2, :), 'ESH') == 1)
	frameType = 'ESH';
	return;
elseif (strcmp(channelsFrameType(1, :), 'LSS') == 1) && (strcmp(channelsFrameType(2, :), 'LPS') == 1)
	frameType = 'ESH';
return;
elseif (strcmp(channelsFrameType(2, :), 'LSS') == 1) && (strcmp(channelsFrameType(1, :), 'LPS') == 1)
	frameType = 'ESH';
return;
elseif (strcmp(channelsFrameType(1, :), 'LSS') == 1) || (strcmp(channelsFrameType(2, :), 'LSS') == 1)
	frameType = 'LSS';
    return;
elseif (strcmp(channelsFrameType(1, :), 'LPS') == 1) || (strcmp(channelsFrameType(2, :), 'LPS') == 1)
	frameType = 'LPS';
	return;
end
frameType='OLS';
return;
end
