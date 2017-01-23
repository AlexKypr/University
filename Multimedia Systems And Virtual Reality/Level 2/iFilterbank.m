% Napoleon-Christos Oikonomou AEM:7952
% Alexandros-Charalampos Kyprianidis AEM:8012

function frameT  =  iFilterbank(frameF, frameType, winType)
%
% Inverse of filterbank

switch frameType
    case 'OLS'
        %in case of OLS we use one long KBD/SIN window
        if(strcmp(winType, 'KBD'))
            window = getWindow(2048,winType,6);
            %apply inverse MDCT to the samples and we pass to time domain
            frameT(:, 1) = imdctv(frameF(:, 1));
            frameT(:, 2) = imdctv(frameF(:, 2));
            %multiply samples with window
            frameT(:, 1) = frameT(:, 1) .* window;
            frameT(:, 2) = frameT(:, 2) .* window;
        elseif(strcmp(winType, 'SIN'))
            %same procedure with KBD window
            window = getWindow(2048,winType,6);
            frameT(:, 1) = imdctv(frameF(:, 1));
            frameT(:, 2) = imdctv(frameF(:, 2));
            frameT(:, 1) = frameT(:, 1) .* window;
            frameT(:, 2) = frameT(:, 2) .* window;
        end
    case 'LSS'
        %in case of LSS we use one long KBD/SIN window and one short
        if(strcmp(winType, 'KBD'))
            longKBDWindow = getWindow(2048,winType,6);
            shortKBDWindow = getWindow(256,winType,4);
            %we choose the appropriate length of each window and we construct our LSS window
            window(1 : 1024) = longKBDWindow(1 : 1024);
            window(1025 : 1472) = 1;
            window(1473 : 1600) = shortKBDWindow(129 : 256);
            window(1601 : 2048) = 0;
            %apply inverse MDCT to the samples and we pass to time domain
            frameT(:, 1) = imdctv(frameF(:, 1));
            frameT(:, 2) = imdctv(frameF(:, 2));
            %multiply samples with window
            frameT(:, 1) = frameT(:, 1) .* window';
            frameT(:, 2) = frameT(:, 2) .* window';
        elseif(strcmp(winType, 'SIN'))
            %same procedure with KBD window
            longSinWindow = getWindow(2048,winType,6);
            shortSinWindow = getWindow(256,winType,4);
            window(1 : 1024) = longSinWindow(1 : 1024);
            window(1025 : 1472) = 1;
            window(1473 : 1600) = shortSinWindow(129 : 256);
            window(1601 : 2048) = 0;
            frameT(:, 1) = imdctv(frameF(:, 1));
            frameT(:, 2) = imdctv(frameF(:, 2));
            frameT(:, 1) = frameT(:, 1) .* window';
            frameT(:, 2) = frameT(:, 2) .* window';
        end
    case 'LPS'
        %in case of LPS we use one long KBD/SIN window and one short
        if(strcmp(winType, 'KBD'))
               longKBDWindow = getWindow(2048,winType,6);
               shortKBDWindow = getWindow(256,winType,4);
               %we choose the appropriate length of each window and we construct our LPS window
               window(1 : 448) = 0;
               window(449 : 576) = shortKBDWindow(1 : 128);
               window(577 : 1024) = 1;
               window(1025 : 2048) = longKBDWindow(1025 : 2048);
               %apply inverse MDCT to the samples and we pass to time domain
               frameT(:, 1) = imdctv(frameF(:, 1));
               frameT(:, 2) = imdctv(frameF(:, 2));
               %multiply samples with window
               frameT(:, 1) = frameT(:, 1) .* window';
               frameT(:, 2) = frameT(:, 2) .* window';
        elseif(strcmp(winType, 'SIN'))
            %same procedure with KBD window
            longSinWindow = getWindow(2048,winType,6);
            shortSinWindow = getWindow(256,winType,4);
            window(1 : 448) = 0;
            window(449 : 576) = shortSinWindow(1 : 128);
            window(577 : 1024) = 1;
            window(1025 : 2048) = longSinWindow(1025 : 2048);
            frameT(:, 1) = imdctv(frameF(:, 1));
            frameT(:, 2) = imdctv(frameF(:, 2));
            frameT(:, 1) = frameT(:, 1) .* window';
            frameT(:, 2) = frameT(:, 2) .* window';
        end
    case 'ESH'
        %in case of ESH we use one short KBD/SIN window
        frameT = zeros(2048, 2);
        testFrame = zeros(128,8,2);
        testFrame(:,:,1) = frameF(:,1:8);
        testFrame(:,:,2) = frameF(:,9:16);
        frameF = testFrame;
        tempFrameF = zeros(128,8,2);
        
        if(strcmp(winType, 'KBD'))
            window = getWindow(256,winType,4);
            %we choose the appropriate samples so that they overlap(for examples 0-256,128-384 and so on)
            
            for i = 0 : 7
               tempFrameF(: ,i + 1, 1) = frameF(:, i + 1, 1);
               tempFrameF(:, i + 1, 2) = frameF(:, i + 1, 2);
               %apply inverse MDCT to every subframe and we pass to time domain
               tempFrameT(:, 1) = imdctv(tempFrameF(:, i+1,1));
               tempFrameT(:, 2) = imdctv(tempFrameF(:, i+1,2));
               %multiply every subframe with window
               tempFrameT(:, 1) = tempFrameT(:, 1) .* window;
               tempFrameT(:, 2) = tempFrameT(:, 2) .* window;
               %set values to frameT
               frameT((448 + i * 128 + 1) : (448 + i * 128 + 256), 1) = frameT((448 + i * 128 + 1) : (448 + i * 128 + 256), 1) + tempFrameT(:, 1);
               frameT((448 + i * 128 + 1) : (448 + i * 128 + 256), 2) = frameT((448 + i * 128 + 1) : (448 + i * 128 + 256), 2) + tempFrameT(:, 2);
            end
        elseif(strcmp(winType, 'SIN'))
            %same procedure with KBD window
            window = getWindow(256,winType,4);
            for i = 0 : 7
               tempFrameF(: ,i + 1, 1) = frameF(:, i + 1, 1);
               tempFrameF(:, i + 1, 2) = frameF(:, i + 1, 2);
               tempFrameT(:, 1) = imdctv(tempFrameF(:, i+1,1));
               tempFrameT(:, 2) = imdctv(tempFrameF(:, i+1,2));
               tempFrameT(:, 1) = tempFrameT(:, 1) .* window;
               tempFrameT(:, 2) = tempFrameT(:, 2) .* window;
               frameT((448 + i * 128 + 1) : (448 + i * 128 + 256), 1) = frameT((448 + i * 128 + 1) : (448 + i * 128 + 256), 1) + tempFrameT(:, 1);
               frameT((448 + i * 128 + 1) : (448 + i * 128 + 256), 2) = frameT((448 + i * 128 + 1) : (448 + i * 128 + 256), 2) + tempFrameT(:, 2);
            end
        end
end
end
