% Napoleon-Christos Oikonomou AEM:7952
% Alexandros-Charalampos Kyprianidis AEM:8012

function frameF = filterbank(frameT,  frameType,  winType)
%
% decrease the correlation of samples with MDCT and passing from time to frequency domain
% checking the frameType
switch frameType
    case 'OLS'
        %in case of OLS we use one long KBD/SIN window
        if(strcmp(winType,  'KBD'))
            weightWindow = getWindow(2048,winType,6);
            %multiply samples with window
            tempFrameT(:, 1) = frameT(:, 1) .* weightWindow;
            tempFrameT(:, 2) = frameT(:, 2) .* weightWindow;
            %apply MDCT to the samples and we pass to frequency domain
            frameF(:, 1) = mdctv(tempFrameT(:, 1));
            frameF(:, 2) = mdctv(tempFrameT(:, 2));
        elseif(strcmp(winType, 'SIN'))
            %same procedure with KBD window
            weightWindow = getWindow(2048,winType,6);
            tempFrameT(:, 1) = frameT(:, 1) .* weightWindow;
            tempFrameT(:, 2) = frameT(:, 2) .* weightWindow;
            frameF(:, 1) = mdctv(tempFrameT(:, 1));
            frameF(:, 2) = mdctv(tempFrameT(:, 2));
        end
    case 'LSS'
        %in case of LSS we use one long KBD/SIN window and one short
        if(strcmp(winType, 'KBD'))
            longKBDWindow = getWindow(2048,winType,6);
            shortKBDWindow = getWindow(256,winType,4);
            %we choose the appropriate length of each window and we construct our LSS window
            weightWindow(1 : 1024) = longKBDWindow(1 : 1024);
            weightWindow(1025 : 1472) = 1;
            weightWindow(1473 : 1600) = shortKBDWindow(129 : 256);
            weightWindow(1601 : 2048) = 0;
            %multiply samples with window
            tempFrameT(:, 1) = frameT(:, 1) .* weightWindow';
            tempFrameT(:, 2) = frameT(:, 2) .* weightWindow';
            %apply MDCT to the samples and we pass to frequency domain
            frameF(:, 1) = mdctv(tempFrameT(:, 1));
            frameF(:, 2) = mdctv(tempFrameT(:, 2));
         elseif(strcmp(winType, 'SIN'))
            %same procedure with KBD window
             longSinWindow = getWindow(2048,winType,6);
             shortSinWindow = getWindow(256,winType,4);
             weightWindow(1 : 1024) = longSinWindow(1 : 1024);
             weightWindow(1025 : 1472) = 1;
             weightWindow(1473 : 1600) = shortSinWindow(129 : 256);
             weightWindow(1601 : 2048) = 0;
             tempFrameT(:, 1) = frameT(:, 1) .* weightWindow';
             tempFrameT(:, 2) = frameT(:, 2) .* weightWindow';
             frameF(:, 1) = mdctv(tempFrameT(:, 1));
             frameF(:, 2) = mdctv(tempFrameT(:, 2));
        end
    case 'LPS'
            %in case of LPS we use one long KBD/SIN window and one short
            if(strcmp(winType, 'KBD'))
               longKBDWindow = getWindow(2048,winType,6);
               shortKBDWindow = getWindow(256,winType,4);
               %we choose the appropriate length of each window and we construct our LPS window
               weightWindow(1 : 448) = 0;
               weightWindow(449 : 576) = shortKBDWindow(1 : 128);
               weightWindow(577 : 1024) = 1;
               weightWindow(1025 : 2048) = longKBDWindow(1025 : 2048);
               %multiply samples with window
               tempFrameT(:, 1) = frameT(:, 1) .* weightWindow';
               tempFrameT(:, 2) = frameT(:, 2) .* weightWindow';
               %apply MDCT to the samples and we pass to frequency domain
               frameF(:, 1) = mdctv(tempFrameT(:, 1));
               frameF(:, 2) = mdctv(tempFrameT(:, 2));
            elseif(strcmp(winType, 'SIN'))
                %same procedure with KBD window
                longSinWindow = getWindow(2048,winType,6);
                shortSinWindow = getWindow(256,winType,4);
                weightWindow(1 : 448) = 0;
                weightWindow(449 : 576) = shortSinWindow(1 : 128);
                weightWindow(577 : 1024) = 1;
                weightWindow(1025 : 2048) = longSinWindow(1025 : 2048);
                tempFrameT(:, 1) = frameT(:, 1) .* weightWindow';
                tempFrameT(:, 2) = frameT(:, 2) .* weightWindow';
                frameF(:, 1) = mdctv(tempFrameT(:, 1));
                frameF(:, 2) = mdctv(tempFrameT(:, 2));
            end
    case 'ESH'
        %in case of ESH we use one short KBD/SIN window
        frameF = zeros(128, 8, 2);
        if(strcmp(winType, 'KBD'))
            weightWindow = getWindow(256,winType,4);
            %we choose the appropriate samples so that they overlap(for examples 0-256,128-384 and so on)
            for i = 0 : 7
                tempT = zeros(256, 2);
                for j = 1 : 256
                    tempT(j, 1) = frameT((448 + i * 128 + j), 1);
                    tempT(j, 2) = frameT((448 + i * 128 + j), 2);
                end
                %for every 256 samples of a sub-frame we multiply with the short window
                tempFrameT(:, 1) = tempT(:, 1) .* weightWindow;
                tempFrameT(:, 2) = tempT(:, 2) .* weightWindow;
                %for every subframe we apply mdct and we pass to frequency domain
                tempF(:, 1) = mdctv(tempFrameT(:, 1));
                tempF(:, 2) = mdctv(tempFrameT(:, 2));
                %set values to frameF
                for j = 1 : 128
                    frameF(j, i+1, 1) = tempF(j, 1);
                    frameF(j, i+1, 2) = tempF(j, 2);
                end
            end
        elseif(strcmp(winType, 'SIN'))
            %same procedure with KBD window
            weightWindow = getWindow(256,winType,4);
            for i = 0 : 7
                tempT = zeros(256, 2);
                for j = 1 : 256
                    tempT(j, 1) = frameT((448 + i * 128 + j), 1);
                    tempT(j, 2) = frameT((448 + i * 128 + j), 2);
                end
                tempFrameT(:, 1) = tempT(:, 1) .* weightWindow;
                tempFrameT(:, 2) = tempT(:, 2) .* weightWindow;
                tempF(:, 1) = mdctv(tempFrameT(:, 1));
                tempF(:, 2) = mdctv(tempFrameT(:, 2));

                for j = 1 : 128
                    frameF(j, i+1, 1) = tempF(j, 1);
                    frameF(j, i+1, 2) = tempF(j, 2);
                end
            end
        end
end
end
